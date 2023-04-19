'''
author : yj
data : 2023/4/18
'''

import serial
import os
from multiprocessing import Process
import threading
import time
import random


'''
PARITY_NONE, PARITY_EVEN, PARITY_ODD, PARITY_MARK, PARITY_SPACE = 'N', 'E', 'O', 'M', 'S'
STOPBITS_ONE, STOPBITS_ONE_POINT_FIVE, STOPBITS_TWO = (1, 1.5, 2)
FIVEBITS, SIXBITS, SEVENBITS, EIGHTBITS = (5, 6, 7, 8)
'''

class mytime():
    def __init__(self):
        self.base_time = time.time()

    def get_time_stamp(self):
        return time.time() - self.base_time

    def reset_time(self):
        self.base_time = time.time()

    def get_real_time(self):
        return time.ctime()

class rs232(object):
    port='COM4'
    baudrate=9600
    bytesize=8  
    parity=serial.PARITY_ODD
    stopbits=1
    timeout=None
    write_timeout=None
    xonxoff=False
    rtscts=False
    dsrdtr=False
    inter_byte_timeout=None
    exclusive=None

    def __init__(self):
        self.shandle = None
        self.shandle = serial.Serial(port=self.port, baudrate= self.baudrate, bytesize = self.bytesize
        ,parity = self.parity, stopbits = self.stopbits, timeout = self.timeout, write_timeout = self.write_timeout
        ,xonxoff = self.xonxoff, rtscts = self.rtscts, dsrdtr= self.dsrdtr,inter_byte_timeout = self.inter_byte_timeout
        ,exclusive = self. exclusive)
        self.time_module = mytime()
        self.read_data = []
        self.write_data = []

    def clear_info(self):
        f = open("report_info.log", "w")
        f.close()

    def clear_report(self):
        f = open("report_report.log", "w")
        f.close()

    def clear_error(self):
        f = open("report_error.log", "w")
        f.close()

    def write_info(self,info: str):
        print(info)
        with open("report_info.log", "a+") as f:
            f.write(info)
    
    def write_report(self,report: str):
        print(report)
        with open("report_report.log", "a+") as f:
            f.write(report)

    def write_error(self,report: str):
        print(report)
        with open("report_error.log", "a+") as f:
            f.write(report)
    
    def open(self):
        if not self.shandle.is_open:
            self.shandle.open()
        self.get_setting()

    def get_setting(self):
        self.write_info("%s\n" %self.shandle.get_settings())
    
    def close(self):
        if self.shandle.is_open:
            self.shandle.close()

    #just for test
    def _read_one_byte(self):
        ret_val = self.shandle.read(1)
        self.write_info("rd_buffer=%d\n" %self.shandle.in_waiting)
        self.write_info("%s\n" %list(ret_val))
        return ret_val

    #just for test
    def _write_data_list(self, data : list ):
        data = bytes(data)
        self.write_info("writing %s\n" %data)
        written_bytes_nu = self.shandle.write(data)
        self.write_info("%d bytes was written\n" %written_bytes_nu)
        self.write_info("wr_buffer=%d\n" %self.shandle.out_waiting)
        self.write_info("wr_buffer=%d\n" %self.shandle.out_waiting)
        self.write_info("wr_buffer=%d\n" %self.shandle.out_waiting)
        self.write_info("wr_buffer=%d\n" %self.shandle.out_waiting)
        self.write_info("wr_buffer=%d\n" %self.shandle.out_waiting)
        self.shandle.flush()
        self.write_info("wr_buffer=%d\n" %self.shandle.out_waiting)
        self.write_info("wr_buffer=%d\n" %self.shandle.out_waiting)
        self.write_info("wr_buffer=%d\n" %self.shandle.out_waiting)
        self.write_info("wr_buffer=%d\n" %self.shandle.out_waiting)
        self.write_info("wr_buffer=%d\n" %self.shandle.out_waiting)

    def write_seq(self,size):
        write_list = []
        #write_list = list(range(size))
        for i in range(size):
            write_list.append(random.randint(0,255))
        write_data = bytes(write_list)
        print(write_data)
        c_time = self.time_module.get_time_stamp()
        self.write_info("[%.3f] %d bytes was writing\n" %(c_time, size))
        if size > 1000: #split each 1000 package
            for i in range(int((size-1)/1000 + 1)):
                print("sending sub_packag %d" %i)
                if (i*1000 + 1000) < size:
                    write_data_sub = write_data[i*1000: i*1000 + 1000]
                else:
                    write_data_sub = write_data[i*1000: size]
                written_bytes_nu = self.shandle.write(write_data_sub)
                c_time = self.time_module.get_time_stamp()
                self.write_info("[%.3f] %d bytes have been written\n" %(c_time,written_bytes_nu))
                time.sleep(0.1)
        else:
            written_bytes_nu = self.shandle.write(write_data)
            c_time = self.time_module.get_time_stamp()
            self.write_info("[%.3f] %d bytes have been written\n" %(c_time,written_bytes_nu))
        self.write_data = write_list

    def read_seq(self,size):
        c_time = self.time_module.get_time_stamp()
        self.write_info("[%.3f] %d bytes was reading\n" %(c_time,size))
        ret_val = self.shandle.read(size)
        c_time = self.time_module.get_time_stamp()
        self.write_info("[%.3f] %d bytes have been read\n" %(c_time,size))
        self.read_data = list(ret_val)

    def run_write_read_seq(self,size):
        for i in range(256):  #256 page
            self.write_seq(size)
            self.read_seq(size)
            self.compare()
            self.check_rd_wr_buff()

    def run(self,size: int):
        wr_t = threading.Thread(target = self.write_seq, args=[size])
        rd_t = threading.Thread(target = self.read_seq,  args=[size])
        wr_t.start()
        rd_t.start()
        wr_t.join()
        rd_t.join()

    def compare(self):
        error_cnt = 0
        pass_cnt = 0
        if len(self.read_data) != len(self.write_data):
            print("read data length not equal to write: rd_length = %d, write_length = %d" %(len(self.read_data), len(self.write_data)))
            if len(self.read_data) < len(self.write_data):
                for j in range(len(self.write_data) - len(self.read_data)):
                    self.read_data.append(0xffff)
            else:
                for j in range(len(self.read_data) - len(self.write_data)):
                    self.write_data.append(0xffff)                
        cmp = 0
        for i in range(len(self.write_data)):
            if self.read_data[i] == self.write_data[i]:
                cmp = 1
            else:
                cmp = 0
            report = "[CMP],[%3d],CMP=%d,write=%d,read=%d\n" %(i,cmp,self.write_data[i],self.read_data[i])
            self.write_report(report)
            if cmp == 0:
                self.write_error(report)
                error_cnt = error_cnt + 1
            else:
                pass_cnt = pass_cnt + 1
        sum_report = "[summary] pass_counts=%d, error_counts=%d" %(pass_cnt, error_cnt)
        self.write_report(sum_report)


    def check_rd_wr_buff(self):
        time.sleep(1)
        report = "[buff_check],out_buffer=%d, in_buff=%d" %(self.shandle.out_waiting, self.shandle.in_waiting)
        self.write_report(report)

if __name__ == "__main__":
    rs232_t = rs232()
    rs232_t.clear_info()
    rs232_t.clear_report()
    rs232_t.clear_error()
    rs232_t.open()
    rs232_t.run_write_read_seq(32)
    rs232_t.close()

    


        






