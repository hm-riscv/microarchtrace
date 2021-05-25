#include <stdint.h>
#include <cstdio>
#include <cstdarg>
#include <cstring>
#include <sys/stat.h>

#include <deque>
#include <verilated.h>

typedef uint32_t timestamp_t;
enum {
    TRACE_ALN = 3,
    TRACE_DEC = 4,
    TRACE_EX1 = 5,
    TRACE_EX2 = 6,
    TRACE_EX3 = 7,
    TRACE_COMMIT = 8,
    TRACE_WB = 9
};

class SwervEH1MicroArchTrace {
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
  id = 3;
  name = "ALN";
  fields := struct {
    uint32_t pc;
  };
};
event {
  id = 4;
  name = "DEC";
  fields := struct {
    uint32_t pc;
  };
};
event {
  id = 5;
  name = "EX1";
  fields := struct {
    uint32_t pc;
  };
};
event {
  id = 6;
  name = "EX2";
  fields := struct {
    uint32_t pc;
  };
};
event {
  id = 7;
  name = "EX3";
  fields := struct {
    uint32_t pc;
  };
};
event {
  id = 8;
  name = "COMMIT";
  fields := struct {
    uint32_t pc;
  };
};
event {
  id = 9;
  name = "WB";
  fields := struct {
    uint32_t pc;
  };
};
)metadata";

public:
  SwervEH1MicroArchTrace() : m_trace(0), m_nextid(0) {}
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

  timestamp_t cur_time() {
    extern vluint64_t main_time;
    return main_time/10;
  }
public:
  void traceALN(uint32_t pc) {
    trace(cur_time(), TRACE_ALN, "L", pc);
  }
  void traceDEC(uint32_t pc) {
    trace(cur_time(), TRACE_DEC, "L", pc);
  }
  void traceEX1(uint32_t pc) {
    trace(cur_time(), TRACE_EX1, "L", pc);
  }
  void traceEX2(uint32_t pc) {
    trace(cur_time(), TRACE_EX2, "L", pc);
  }
  void traceEX3(uint32_t pc) {
    trace(cur_time(), TRACE_EX3, "L", pc);
  }
  void traceCOMMIT(uint32_t pc) {
    trace(cur_time(), TRACE_COMMIT, "L", pc);
  }
  void traceWB(uint32_t pc) {
    trace(cur_time(), TRACE_WB, "L", pc);
  }
};

static SwervEH1MicroArchTrace trace;

extern "C" {
  void trace_init() {
    trace.init();
  }
  void trace_aln(int pc) {
    trace.traceALN(pc);
  }
  void trace_dec(int pc) {
    trace.traceDEC(pc);
  }
  void trace_ex1(int pc) {
    trace.traceEX1(pc);
  }
  void trace_ex2(int pc) {
    trace.traceEX2(pc);
  }
  void trace_ex3(int pc) {
    trace.traceEX3(pc);
  }
  void trace_commit(int pc) {
    trace.traceCOMMIT(pc);
  }
  void trace_wb(int pc) {
    trace.traceWB(pc);
  }

}
