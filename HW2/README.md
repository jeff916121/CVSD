# Verilog Simulation

[TOC]

## 在 Home目錄做
### 1.設定在vim中顯示行數
```vim .vimrc```
```vimrc=
set nu 
```

### 2.vim要叫關介面的指令
```shift+; ```  輸入 ```+q``` 可以離開

## 在要跑verilog的目錄做
### 1.寫好 rtl_file
設定要合成的RTL file
```vim rtl_file```
```rtl_file=
path.v
fifo.v
```
> 若fifo.v被include 到path.v檔裡面
rtl_file中就不需要寫
意即若在path.v中加入``` `include "fifo.v"```，那就rtl_file的內容要改為
```rtl_file=
path.v
```


### 2.tcl  tickle(搔癢、自發性抽動) 腳本

#### 2-1. 編輯00.tcl

```tcl=
# vim 00.tcl
source /usr/cadence/cshrc
source /usr/spring_soft/CIC/verdi.cshrc
```

#### 2-2. 編輯01_rtl_simulation.tcl
```tcl=
# vim 01_rtl_simulation.tcl
ncverilog tb.v -f rtl_file +access+rwc +define+VCD +define+FSDB +define+MDA
verdi -ssf tb.fsdb &
```
> 請不要像某人一樣把 +define換到下一行去，這必須打在同一行，否則指令可能就不會正常執行，然後找bug找很久 (這是真實案例喔，一個帥哥跑來找我debug一天) 

```+access+rwc``` 是為了看內部的訊號

### 3.在testbench中加入
```vim tb.v```
```testbench=
initial begin
	`ifdef FSDB
		$fsdbDumpfile("tb.fsdb");
		$fsdbDumpvars;
	`endif

	`ifdef VCD
		$dumpfile("tb.vcd");
		$dumpvars;
	`endif

	`ifdef MDA
		$fsdbDumpMDA;
	`endif
end
```
若在command line有告訴testbench有定義FSDB、VCD、MDA，就會執行裡面的指令，MDA是用來看陣列的數值

### 4. source 寫好的tcl檔
```source 00.tcl```
```source 01_rtl_simulation.tcl```
也可將這兩個指令寫在  ```02_rtl_simulation.tcl```，最後在空一行，這樣做自動化會更方便
```vim 02_rtl_simulation.tcl```
```tcl=
source 00.tcl
source 01_rtl_simulation.tcl
```

### 5.在nWave中按 “g”

### 6.若有更新tb.v，重新run，把新打開的verdi關掉，把舊的nWave波型reload
或者是在寫一個```03_rtl_simulation.tcl```，把要打開Verdi的指令拿掉，最後再空一行
```vim 03_rtl_simulation.tcl```
```tcl=
ncverilog tb.v -f rtl_file +access+rwc +define+VCD +define+FSDB +define+MDA

```
