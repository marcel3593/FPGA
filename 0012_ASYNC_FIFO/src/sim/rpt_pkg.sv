package rpt_pkg;
  typedef enum {INFO, WARNING, ERROR, FATAL} report_t;
  typedef enum {LOW, MEDIUM, HIGH, TOP}severity_t;
  typedef enum {LOG, STOP, EXIT} action_t;

  static severity_t svrt = MEDIUM;
  static report_t rpt_error = ERROR;
  static string logname = "report.log";
  static string logname_error = "report_error.log";
  static string logname_info = "report_info.log";
  static int info_count = 0;
  static int warning_count = 0;
  static int error_count = 0;
  static int fatal_count = 0;

  function void rpt_msg(string src, string i, report_t r=INFO, severity_t s=LOW, action_t a=LOG);
    integer logf;
    integer logf_error;
    integer logf_info;
    string msg;
    case(r)
      INFO: info_count++;
      WARNING: warning_count++;
      ERROR: error_count++;
      FATAL: fatal_count++;
    endcase
    if(s >= svrt) begin
      msg = $sformatf("@%0t [%s] %s : %s", $time, r, src, i);
      logf = $fopen(logname, "a+");
      $display(msg);
      $fwrite(logf, $sformatf("%s\n", msg));
      $fclose(logf);
      if (r >= rpt_error) begin
        logf_error = $fopen(logname_error, "a+");
        $fwrite(logf_error, $sformatf("%s\n", msg));
        $fclose(logf_error);
      end
      if(a == STOP) begin
        $stop();
      end
      else if(a == EXIT) begin
        $finish();
      end
    end
    else begin
      msg = $sformatf("@%0t [%s] %s -->", $time, r, src);
      logf_info = $fopen(logname_info, "a+");
      $display(msg);
      $fwrite(logf_info, $sformatf("%s\n", msg));
      $display(i);
      $fwrite(logf_info, i);
      $fclose(logf_info);
    end
  endfunction

  function void do_report();
    string s;
    s = "\n---------------------------------------------------------------\n";
    s = {s, "REPORT SUMMARY\n"}; 
    s = {s, $sformatf("info count: %0d \n", info_count)}; 
    s = {s, $sformatf("warning count: %0d \n", warning_count)}; 
    s = {s, $sformatf("error count: %0d \n", error_count)}; 
    s = {s, $sformatf("fatal count: %0d \n", fatal_count)}; 
    s = {s, "---------------------------------------------------------------\n"};
    rpt_msg("[REPORT]", s, rpt_pkg::INFO, rpt_pkg::TOP);
  endfunction

  function void clean_log();
    integer logf, logf_error, logf_info;
    logf = $fopen(logname, "w");
    $fclose(logf);
    logf_error = $fopen(logname_error, "w");
    $fclose(logf_error);
    logf_info = $fopen(logname_info, "w");
    $fclose(logf_info);
  endfunction
endpackage
