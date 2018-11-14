# CVSD HW3

 

## 題目說明
要從ROM中出現1的前景，判斷他八個方位是否有跟他連通的點，如果有，他們就是同一個group，而不同group間會有不同的編號，最後要把編號完的值寫入SRAM

## code時要小心的細節
1.SRAM和ROM寫入和讀資料時，address和data在正緣給，負緣才會拿到值，因此寫入資料的位置必需要慢一個clock <br/>
(1) 在讀取資料時，資料已經延遲了一個clock，所以必須把上一個clock的address存起來，可以採用做delay的方式，也就是說送給ROM的address會比拿到資料後要寫入自己memory的address快一個clock
(2) 在填寫資料時，填寫的address(送給SRAM的)要慢一個clock<br/>
2.若一個訊號同時由多個always block給值，在合成時會不知道要聽誰的<br/> <br/>

## 方法

1.**方法一**

**想法**
把ROM的值讀出來，想辦法把ROM map的值Label後轉到Label map，拜訪過的點會在Visit map標記1。<br/>

**需要**
(1)一個ROM map:    [7:0] ROM [0:127]
利用這個map來尋找需要被標記的Pattern，一次只會處理一種Pattern
(2)一個Label map:    [2:0] Label [0:1023]
利用這個map來記錄Pattern的編號，並根據這個map來寫SRAM的值
(3)一個Visit map:    Visit [0:1023]
利用這個map來紀錄過拜訪過八個方位的點，並尋找下一個應該拜訪group member八個方位的位置<br/>

**困難之處**
若你是由上往下、由左往右掃，麻煩之處只有當左、左上、上、右上方有人要處理時，ROM index要減五，如此處理時間可能會慢別人一點
判斷條件上需要的參數也比較多

**步驟**
1.把ROM的值讀到ROM map
2.套用下方的演算法，把ROM map的資訊轉到Label map
3.把Label map的值，花1024個clock cycles寫到SRAM

**演算法步驟**
(1)尋找New Pattern的位置
```sudocode=
if(ROM[x][y]==1) begin
    //紀錄他的x、y座標，並以他為中心點
    scanx=x;
    scany=y;
    //要準備拜訪他的八個方位，要在Visit map設為拜訪過
    Visit[x][y]=1;
end
``` 
(2)利用尋找到pattern member的位置，對照ROM map，一次尋找八個方位出現1的位置，並在Label map上設值，之後把ROM map中的1設為0，以此來加速尋找上的方便(不會被其他group pattern再看到)，最後對照Visit map，要把中心點位置設為1，代表這個點已經被拜訪過(看過八個方位)。


```sudocode=
if(ROM[八個方位的x][八個方位的y]==1) begin
    Label[八個方位的x][八個方位的y]=Labelvalue;
    ROM[八個方位的x][八個方位的y]=0;
    Visit[中心點的x][中心點的y]=1;
end
```
上面code中的八個方位只是示意，要在combinational block中寫上八組if、else

為了判斷的方便，若有Label到左、左上、上、右上的位置，建議把尋找的X座標-5(-5是考慮ROM的邊界條件，可能左上的X index會差5)，若無就繼續掃下去<br/>
(3)藉由對照Label和Visit map尋找中心點的位置

```sudocode=
if(Label!=0 && Vist==0) begin
    //有被Label，卻還沒被拜訪過的點
    //紀錄他的x、y座標，並以他為中心點
    scanx=x;
    scany=y;
    //要準備拜訪他的八個方位，要在Visit map設為拜訪過
    Visit[x][y]=1;
end
``` 
<br/>

(4)重複(2)、(3)的步驟，一直到把這個Pattern在ROM map中有出現1的位置，都Label到Label map上

(5)當八個方位的ROM map和Label map都不再有1，從第一步開始重新做，尋找下一組New pattern，由於拜訪過的點會被從ROM map中移出，所以不用擔心Pattern會被重新找到

(6)若掃到ROM index=127的位置，則結束Pattern的Label






<br/>

2.**方法二**


**想法**
把ROM的值讀出來，想辦法把ROM map的值Label後紀錄在Label map，透過conflict point，建出一個二維的table，把等效的數值link起來，最後再重新掃一次Label map，讓等效的值透過查表後換成一致的值
<br/>



**需要**
(1)一個ROM map:    [7:0] ROM [0:127]
利用這個map來尋找需要被標記的Pattern
(2)一個Label map:    [2:0] Label [0:1023]
利用這個map來記錄Pattern的編號，並根據這個map來寫SRAM的值
(3)一個二維的table map:    table [0:13][0:13]
利用查table，去把等效的Label替換成一致的Label
table需要開多大取決於癥結點會抓到幾種不同的value，也就是說會取決於癥結點(可能發生在轉折處或孤立處)的個數<br/>

**困難之處**
這個table比較難用verilog的想法maintain

**table map的說明**
在二維table中出現1，代表兩個index是等價的，出現0則代表不同，首先會在對角線都寫上1，其他點寫入0，而當癥結點發生時，會把癥結值的關聯性紀錄到table中，此外我們只關心從左到右第一個發生1的位置，因此就可以確保大家會被更換到一定值
舉例來說，若3、5、6是等價的Labelvalue
```
table[3][3]=1;
table[3][5]=1;
table[3][6]=1;
table[5][3]=1;
table[5][5]=1;
table[5][6]=1;
table[6][3]=1;
table[6][5]=1;
table[6][6]=1;
```
若都選取最左邊發生true的index，可以確保同一個group會被更新成一樣的Labelvalue，以此例子來說，5、6都會被更新成3


(1)table的建立
舉例來說，假設3、5、6這三個值為等價的Label，同一個group必須Label上一樣的數字，為了方便說明，我們都mark成最小的數字
首先在table的對角線，也就是table[3][3]、table[5][5]、table[6][6]都mark上1
假設癥結點讓我們找到3跟5是等價的，5跟6是等價的
則table[3][5]、table[5][3]、table[5][6]、table[6][5]也要被mark上1
這邊講的癥結點是指它的左、左上、上、右上有著不同的Label值
透過癥結點，我們會採取以下的動作
```sudocode=
    table[3][3]=1;
    table[5][5]=1;
    table[6][6]=1;
    
    if(癥結點條件發生) begin
        table[3][5]=1;
        table[5][3]=1;
        table[5][6]=1;
        table[6][5]=1;
    end
```
(2)table的處理
輸入index透過遞迴查表得到最早發生關聯性的index值，一直到輸入和輸出的index值相同時結束這個index的關聯性處理，而每個index都要處理一次。
舉例說明:我們必須在6和3之間也建立關聯，因為它們也應該是等價的值，所以我們可以透過table[6]去尋找有關連性的點，我們可以找到5，再去查table[5]去尋找有關連性的點，我們可以找到3，再去查table[3]去尋找有關連的點，我們可以找到3，而透過查表得出來的index值和原本輸入的index值是一致的，所以我們就會在原本table[6]中，在index=3的地方也記錄1
```sudocode=
    table[6][調整y1直到找到true的index]=1;
    table[y1][調整y2直到找到true的index]=1;
    ...
    table[yk][調整yk+1直到找到true的index]=1;
    //做到最後yk+1等於yk時結束
```


**步驟**
1.把ROM的值讀到ROM map
2.套用下方的演算法，透過ROM map建立出Label map
3.在建立Label map的過程中，透過癥結點把等價的Labelvalue紀錄在二維的table中
4.處理二維的table
5.重新掃一次Label map，並透過查表的方式把同一個group的pattern給予一致性的label
6.把Label map的值寫入SRAM中

**演算法步驟**
(1)尋找Pattern起點:掃描x和y，當在ROM map中遇到為1的位置停下來，若它的左、左上、上、右上方都沒有被Label過，幫它在Label map上Label上一個值，並把左、左上、上、右上方中ROM map也有1的位置給Label，然後把掃描ROM x的index-5，讓那四個方位能夠再Label到其他點

(2)若在(1)中，有人被Label過，且Label編號一致，則把它們的Label assign到這個點來

```sudocode=
if(ROM[x][y]==1 && 左、左上、上、右上的Label都為0) begin
    Label[x][y]=Labelvalue;
    Label[四個方位有出現1的x座標][四個方位有出現1的y座標]=Labelvalue;
    scanx=x-5;
end
else if(左、左上、上、右上的Label有人為1且Label都一致) begin
    Label[x][y]=上下左右有1處的Label值
end
``` 
(3)若在(2)中遇到四個方位的Label不同，則把有癥結的值存到二維的table中
```sudocode=
if(Labe1!=Label2) begin
    table[Label1][Label2]=1;
    table[Label2][Label1]=1;
end
```
(4)重複(1)~(3)的動作，直到把ROM map全部掃完一遍

(5)套用上方提過**table map的說明**來處理table

(6)重新掃一次Label map，把每個Labelvalue都帶進table中，把得到的值寫回Label map
這一步可以1次掃1024個點，速度會比較快，但相較面積也會比較大

(7)把處理完的Label map寫入SRAM

[Two pass 演算法參考文獻](https://zh.wikipedia.org/wiki/%E8%BF%9E%E9%80%9A%E5%88%86%E9%87%8F%E6%A0%87%E8%AE%B0)



3.**方法三**
類似方法二，只是每個點都有一個shift register，然後開1024組，每次中心點都被assign成周遭最小的值，這招更新蠻快的但相對硬體也會較大


4.**方法四**
Queue
個人最喜歡這招，時間非常快，但especially for sparse matrix

[HW3 Github](https://github.com/jeff916121/CVSD/tree/master/HW3)

[One pass 演算法參考文獻](https://en.wikipedia.org/wiki/Connected-component_labeling?fbclid=IwAR2jYDdEuuO_YQXG1Q_medgR66T8G098Ffk-H1RJ_nZxQ2e5GSjHSYtxL_c)



AT^2=4E12的那位太誇張了啦


[某大神的作品 很炫 很帥](https://github.com/yutongshen/ICContest-2016-Final-ComponentLabelingEngine)