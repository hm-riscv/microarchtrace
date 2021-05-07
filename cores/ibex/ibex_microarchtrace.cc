#include <stdint.h>
#include <cstdio>
#include <cstdarg>
#include <cstring>
#include <sys/stat.h>

#include <verilator_sim_ctrl.h>

#include <deque>

typedef uint32_t timestamp_t;
enum {
  TRACE_IF = 0,
  TRACE_IDEX = 1,
  TRACE_WB = 2,
  TRACE_DONE = 3
};

class IbexMicroArchTrace {
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
    };
};

event {
  id = 0;
  name = "IF";
  fields := struct {
    uint32_t insn_id;
    uint32_t pc;
    uint8_t mode;
    enum : uint8_t { regular, compact } insn_type;
    variant <insn_type> {
      uint32_t regular;
      uint16_t compact;
    } insn;
  };
};
event {
  id = 1;
  name = "IDEX";
  fields := struct {
    uint32_t insn_id;
    uint32_t pc;
  };
};
event {
  id = 2;
  name = "WB";
  fields := struct {
    uint32_t insn_id;
    uint32_t pc;
  };
};
event {
  id = 3;
  name = "DONE";
  fields := struct {
    uint32_t insn_id;
    uint32_t pc;
  };
};
)metadata";

public:
  IbexMicroArchTrace() : m_trace(0), m_IFStart(0), m_IDEXStart(0), m_nextid(0), m_idexid(0), m_wbid(UINT32_MAX) {}
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
  timestamp_t m_IFStart;
  timestamp_t m_IDEXStart;
  uint32_t m_nextid;
  uint32_t m_idexid;
  uint32_t m_wbid;

  timestamp_t cur_time() {
    return VerilatorSimCtrl::GetInstance().GetTime() >> 1;
  }
public:
  void traceIFStart() {
    m_IFStart = cur_time();
  }
  void traceIF(bool multi, uint32_t pc, uint32_t insn, uint8_t mode, uint8_t c, uint16_t c_insn) {
    timestamp_t time = multi ? m_IFStart : cur_time();
    if (c)
      trace(time, TRACE_IF, "LLBBH", m_nextid++, pc, mode, 1, c_insn);
    else
      trace(time, TRACE_IF, "LLBBL", m_nextid++, pc, mode, 0, insn);
  }
  void traceIDEX(uint32_t pc) {
    m_idexid = m_nextid-1;
    trace(cur_time(), TRACE_IDEX, "LL", m_idexid, pc);
  }
  void traceWB(uint32_t pc) {
    m_wbid = m_nextid-2;
    trace(cur_time(), TRACE_WB, "LL", m_wbid, pc);
  }
  void traceDone(uint32_t pc) {
    if (m_wbid != UINT32_MAX) {
      trace(cur_time(), TRACE_DONE, "LL", m_wbid, pc);
    } else {
      trace(cur_time(), TRACE_DONE, "LL", m_idexid, pc);
    }
  }
};

static IbexMicroArchTrace trace;

extern "C" {
  void trace_init() {
    trace.init();
  }

  void trace_if(int pc, int insn, char mode, svLogic c, short int c_insn) {
    trace.traceIF(false, pc, insn, mode, c, c_insn);
  }

  void trace_if_start() {
    trace.traceIFStart();
  }

  void trace_if_end(int pc, int insn, char mode, svLogic c, short int c_insn) {
    trace.traceIF(true, pc, insn, mode, c, c_insn);
  }

  void trace_idex(int pc) {
    trace.traceIDEX(pc);
  }

  void trace_wb(int pc) {
    trace.traceWB(pc);
  }

  void trace_done(int pc) {
    trace.traceDone(pc);
  }
}
