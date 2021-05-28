#include <stdint.h>
#include <cstdio>
#include <cstdarg>
#include <cassert>
#include <cstring>
#include <sys/stat.h>

#include <deque>

#include <iostream>

typedef uint32_t timestamp_t;
enum {
  TRACE_IF = 0,
  TRACE_DE = 1,
  TRACE_EX = 2,
  TRACE_WB = 3
};

extern double sc_time_stamp();

class SwervEL2MicroArchTrace {
private:
  FILE *m_trace;
  const char *metadata = R"metadata(/* CTF 1.8 */
trace {
  major = 1;
  minor = 8;
  byte_order = le;
};

typealias integer {
    size = 32;
    signed = false;
    base = hex;
    align = 8;
} := uint32_t;

typealias integer {
    size = 16;
    signed = false;
    base = hex;
    align = 8;
} := uint16_t;

typealias integer {
    size = 8;
    signed = false;
    base = hex;
    align = 8;
} := uint8_t;

stream {
    event.header := struct {
      uint32_t timestamp;
      uint8_t id;
      uint32_t insn_id;
    };
};

event {
  id = 0;
  name = "IF";
  fields := struct {
    uint32_t pc;
    uint32_t insn;
  };
};

event {
  id = 1;
  name = "DE";
  fields := struct {
  };
};

event {
  id = 2;
  name = "EX";
  fields := struct {
  };
};

event {
  id = 3;
  name = "WB";
  fields := struct {
  };
};
  )metadata";

public:
  SwervEL2MicroArchTrace() : m_trace(0), m_nextid(0) {}

  void init() {
    mkdir("trace", 0777);
    FILE* metadataf = fopen("trace/metadata", "w");
    fwrite(metadata, 1, strlen(this->metadata), metadataf);
    fclose(metadataf);
    m_trace = fopen("trace/trace", "wb");
  }

  void trace(timestamp_t time, uint8_t id, const char* pfmt, ...) {
    va_list args;
    va_start(args, pfmt);

    fwrite(&time, sizeof(timestamp_t), 1, m_trace);
    fwrite(&id, 1, 1, m_trace);

    for(; *pfmt != '\0'; ++pfmt) {
      if ((*pfmt == 'i') || (*pfmt == 'l')) {
        int32_t v = va_arg(args, int32_t);
        fwrite(&v, 4, 1, m_trace);
      } else if ((*pfmt == 'I') || (*pfmt == 'L')) {
        uint32_t v = va_arg(args, uint32_t);
        fwrite(&v, 4, 1, m_trace);
      } else if (*pfmt == 'h') {
        int16_t v = va_arg(args, int);
        fwrite(&v, 2, 1, m_trace);
      } else if (*pfmt == 'H') {
        uint16_t v = va_arg(args, int);
        fwrite(&v, 2, 1, m_trace);
      } else if (*pfmt == 'b') {
        int8_t v = va_arg(args, int);
        fwrite(&v, 1, 1, m_trace);
      } else if (*pfmt == 'B') {
        uint8_t v = va_arg(args, int);
        fwrite(&v, 1, 1, m_trace);
      }
    }
  }
private:
  uint32_t m_nextid;
  typedef struct { timestamp_t time; uint32_t pc; } if_t;
  std::deque<if_t> m_if;
  typedef struct { uint32_t id; uint32_t pc; } de_t;
  std::deque<de_t> m_de;
  typedef struct { uint32_t id; uint32_t pc; } ex_t;
  std::deque<ex_t> m_ex;
  std::deque<ex_t> m_load;

  timestamp_t cur_time() {
    return (timestamp_t) sc_time_stamp()/10;
  }
public:
  void traceIF(uint32_t pc) {
    m_if.push_back({.time = cur_time(), .pc = pc});
  }
  void traceDE(uint32_t pc, uint32_t insn) {
    if_t i;
    do {
      if (m_if.empty()) { std::cout << "empty :(" << std::endl; return; }
      //assert(!m_if.empty());

      i = m_if.front();
      if (i.pc == pc) {
        break;
      }
      if (i.pc+2 == pc) {
        // unaligned
        m_if.pop_front(); // We won't see this again
        break;
      }
      if (i.pc+4 == pc) {
        // previous one, clean up
        m_if.pop_front();
      } else {
        // flushed something, TODO: generate packet for this
        m_if.pop_front();
      }
    } while (true);
    uint32_t id = m_nextid++;
    trace(i.time, TRACE_IF, "LLL", id, pc, insn);
    trace(cur_time(), TRACE_DE, "L", id);
    m_de.push_back({.id = id, .pc = pc});
  }
  void traceEX(uint32_t pc) {
    de_t i = m_de.front(); m_de.pop_front();
    assert(pc == i.pc);
    trace(cur_time(), TRACE_EX, "L", i.id);
    m_ex.push_back({.id = i.id, .pc = i.pc});
  }
  void traceLoad(uint32_t pc) {
    de_t i = m_de.front(); m_de.pop_front();
    assert(pc == i.pc);
    trace(cur_time(), TRACE_EX, "L", i.id);
    m_load.push_back({.id = i.id, .pc = i.pc});
  }
  void traceWB(uint32_t pc) {
    if (m_ex.size() == 0) {
      return;
    }
    ex_t i = m_ex.front();
    if (pc == i.pc) {
       m_ex.pop_front();
       trace(cur_time(), TRACE_WB, "L", i.id);
    }
  }
  void traceLoadWB() {
    ex_t i = m_load.front(); m_load.pop_front();
    trace(cur_time(), TRACE_WB, "L", i.id);
  }
  void print_state() {
    printf("m_nextid=%d\n", m_nextid);
    printf("m_de.size()=%d\n", m_de.size());
  }
};

static SwervEL2MicroArchTrace trace;

extern "C" {
  void trace_init() {
    trace.init();
  }

  void trace_if(int pc) {
    trace.traceIF(pc);
  }

  void trace_de(int pc, int insn) {
    trace.traceDE(pc, insn);
  }

  void trace_ex(int pc ) {
    trace.traceEX(pc);
  }

  void trace_load(int pc) {
    trace.traceLoad(pc);
  }

  void trace_wb(int pc) {
    trace.traceWB(pc);
  }

  void trace_loadwb() {
    trace.traceLoadWB();
  }
};
