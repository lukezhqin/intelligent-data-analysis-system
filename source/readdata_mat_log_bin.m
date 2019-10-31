function idasdata=readdata_mat_log_bin(File,varlist)
% Copyright @XXX 2017-2019 All Rights Reserved.#
% Author   : Anakin.Qin  2017.12.26 11:16:24   #
% Website  : https://anakinqin.github.io       #
% E-mail   : zonghang.qin@foxmail.com          #
% Intelligent Data Analysis System(IDAS)
%这部分在按照行分析fread数据时可以考虑采用并行计算
%% 显示进度条
SizeofFile=0;
newfileinfo=cell(length(File),1);
for i=1:length(File)
    newfileinfo{i} = dir(File{i});
    SizeofFile=SizeofFile+newfileinfo{i}.bytes;
end
% TimeToRead=SizeofFile/139699962*4;% 读取137MB数据大概要4s
TimeToRead=SizeofFile/139699962*6;%稍微夸大点耗时数据
strDisp='';
strName=sprintf('数据读取中，约需时%ds',round(TimeToRead));
hwaitbar = waitbar(0,strDisp,'Name',strName);
set(get(get(hwaitbar,'Children'),'Title'),'Interpreter','none'); % waitbar实际上是一个figure，strDisp所在的'message'是其中axes的标题
%% 读取数据
if ~iscell(File)
    File={File};
end
nfile=length(File);
nvar=length(varlist);
idasdata=repmat([],nfile);
try
    for iFile=1:nfile
        [pathstr, name, ext] = fileparts(File{iFile});
        strDisp=['读取' name ext,' ...'];
        waitbar((iFile-1)/nfile,hwaitbar,strDisp)
        idasdata{iFile}.File=File{iFile};
        idasdata{iFile}.varlist=varlist;%读取mat/log格式文件
        [idasdata{iFile}.Time,idasdata{iFile}.Data,idasdata{iFile}.label,idasdata{iFile}.logfeq]=readmatlogfile(File,iFile,varlist);
        waitbar(iFile/nfile,hwaitbar,strDisp)
    end
catch
    fclose all;
    delete(hwaitbar);%close(hwaitbar);关闭读取的进度条，显示读取错误界面
    errordlg(lasterr,'文件读取错误');
    rethrow(lasterror);
end
delete(hwaitbar);
end

function y=calc_intvel(data,no)


if no==1
    from=1;
    to=data(1);
else
    sum=0;
    num=no-1;
    for i=1:num
        sum=sum+data(i);
    end
    from=sum+1;
    sum=0;
    for i=1:no
        sum=sum+data(i);
    end
    to=sum;
end


y=[from to];
end

function y=isvalidlabel(x,nameset,datafile)
y = false;
flag = false;
try
    vstr=getfield(datafile,x(1:length(x)-6));
    if ~isempty(vstr)
        flag = true;
    end
catch ce
    if(strcmp(ce.identifier,'MATLAB:nonExistentField'))
        fprintf('找不到数据“%s”.\n',x);
    end
    %rethrow(ce)%去掉该数据标签
end
if flag
    for i=1:length(nameset)
        if strcmp(x,nameset{i})
            y=true;
            return;
        end
    end
end
end

function ptr=idx_data2set(label_2,str)
%注意label_2含有双倍标签
len=length(label_2);
for i=1:len
    if (strcmp(label_2{i},str))
        ptr=i/2;
        return;
    end
end
end

function y=mysort_dash(x)
%only to sort the char before the dash signal "_"
lenx=length(x);
y=cell(lenx,1);
t=cell(lenx,1);
for i=1:lenx
    tokens=textscan(x{i},'%s','Delimiter','_');
    tokens=tokens{1};
    t{i}=tokens{1};
end
[~,idx]=sort(t);
for i=1:lenx
    y{i}=x{idx(i)};
end
end

function y=apminfo_str2double(x)
% for the APM open source code, we may got string format info, so we can
% transfer it in this function
%     STABILIZE =     0,  // manual airframe angle with manual throttle
%     ACRO =          1,  // manual body-frame angular rate with manual throttle
%     ALT_HOLD =      2,  // manual airframe angle with automatic throttle
%     AUTO =          3,  // fully automatic waypoint control using mission commands
%     GUIDED =        4,  // fully automatic fly to coordinate or fly at velocity/direction using GCS immediate commands
%     LOITER =        5,  // automatic horizontal acceleration with automatic throttle
%     RTL =           6,  // automatic return to launching point
%     CIRCLE =        7,  // automatic circular flight with automatic throttle
%     LAND =          9,  // automatic landing with horizontal position control
%     DRIFT =        11,  // semi-automous position, yaw and throttle control
%     SPORT =        13,  // manual earth-frame angular rate control with manual throttle
%     FLIP =         14,  // automatically flip the vehicle on the roll axis
%     AUTOTUNE =     15,  // automatically tune the vehicle's roll and pitch gains
%     POSHOLD =      16,  // automatic position hold with manual override, with automatic throttle
%     BRAKE =        17,  // full-brake using inertial/GPS system, no pilot input
%     THROW =        18,  // throw to launch mode using inertial/GPS system, no pilot input
%     AVOID_ADSB =   19,  // automatic avoidance of obstacles in the macro scale - e.g. full-sized aircraft
%     GUIDED_NOGPS = 20,  // guided mode but only accepts attitude and altitude
%
%     Auto_TakeOff,
%     Auto_WP,
%     Auto_Land,
%     Auto_RTL,
%     Auto_CircleMoveToEdge,
%     Auto_Circle,
%     Auto_Spline,
%     Auto_NavGuided,
%     Auto_Loiter,
%     Auto_NavPayloadPlace,
%
%     Guided_TakeOff,
%     Guided_WP,
%     Guided_Velocity,
%     Guided_PosVel,
%     Guided_Angle,
y = str2double(x);
if isnan(y)
    nameset={'STABILIZE','ACRO','ALT_HOLD','AUTO','GUIDED','LOITER','RTL','CIRCLE','LAND','DRIFT','SPORT','FLIP','AUTOTUNE','POSHOLD','BRAKE','THROW','AVOID_ADSB','GUIDED_NOGPS',...
        'Auto_TakeOff','Auto_WP','Auto_Land','Auto_RTL','Auto_CircleMoveToEdge','Auto_Circle','Auto_Spline','Auto_NavGuided','Auto_Loiter','Auto_NavPayloadPlace',...
        'Guided_TakeOff','Guided_WP','Guided_Velocity','Guided_PosVel','Guided_Angle'};
    valset=[0,1,2,3,4,5,6,7,9,11,13,14,15,16,17,18,19,20,...
        0,1,2,3,4,5,6,7,8,9,...
        0,1,2,3,4];
    try
        % got char kind info
        for i=1:length(valset)
            flag=strcmpi(x,nameset{i});
            if (flag)
                y=valset(i);
                break;
            end
        end
    catch
        warndlg(lasterr,'Wrong flight mode string');
        rethrow(lasterror);
    end
end
end


function [timeset,dataset,tnulab,log_feq]=readmatlogfile(File,iFile,varlist)
rootpath=pwd;
[~, ~, ext] = fileparts(File{iFile});
if (strcmpi(ext,'.log'))
    %% 读取log格式文件
    %读取配置文件，该文件写明了需要转换的变量，忽略不存在的变量
    %读取是否需要采用并行计算的自定义选项
    cfgname='Configuration_AnakinQin.cfg';
    cfgfpath=strcat(rootpath,'\',cfgname);
    fid=fopen(cfgfpath);
    if fid==-1
        %未找到正确的配置文件
        fprintf('Cannot find "%s" file in path:<"%s">!!\n\n\n',cfgfpath,cfgname);
        errordlg('Cannot find ".cfg" file in root path');
        return;
    end
    flag=1;
    while flag
        skip=fgetl(fid);
        tokens=textscan(skip,'%s','Delimiter','_');
        tokens=tokens{1};
        flag=~strcmp(tokens{1},'@@@');
    end
    for i=1:5
        fgetl(fid);
    end
    %从配置文件读取是否需要开启并行池
    isuse_parcalc=logical(str2double(fgetl(fid)));
    %缓存限制下的缩小倍数（默认全量缓存，仅当报错内存溢出时进行修改即可，数字为除法被除数，数值越大，缓存区间缩放效果越强）
    fgetl(fid);
    buffsize_divd=round(str2double(fgetl(fid)));
    if(buffsize_divd<1)
        buffsize_divd=1;
    end
    fclose(fid);
    %数据读取
    fid = fopen(File{iFile});
    if (fid==-1)
        errordlg('Corruption in file system！');
        return;
    end
    flinedata=cell(2,1);
    i=0;
    while(~feof(fid))
        i=i+1;
        flinedata{i}=fgetl(fid);
    end
    fclose(fid);
    len_fline=i;
    %handle the varlist to formulation like loadfile itself
    label2set=cell(2,1);
    t=0;
    m=1;
    var_lenset=zeros(2,1);
    for i=1:length(varlist)
        tokens=textscan(varlist{i},'%s','Delimiter','_');
        tokens=tokens{1};
        if (isempty(label2set{1}))
            label2set{1}=strcat(tokens{1},'_label');
            label2set{2}=tokens{1};
            t=t+3;%mat language start from 1!!!
        end
        if (~strcmp(label2set{end},tokens{1}))
            %because the input varlist is sorted from the outside ,so we
            %just need to check from the last cell of the label2set value;
            label2set{t}=strcat(tokens{1},'_label');
            label2set{t+1}=tokens{1};
            t=t+2;
            m=m+1;
            if(m<=length(var_lenset))
                var_lenset(m)=var_lenset(m)+1;
            else
                var_lenset=[var_lenset;0];
                var_lenset(m)=var_lenset(m)+1;
            end
        else
            var_lenset(m)=var_lenset(m)+1;
        end
    end
    var_lenset=var_lenset+2;%add the LineNo and timeus data
    %init set field to loadfile struct
    len_field2set=length(label2set);
    loadfile=struct;
    data2set=cell(len_field2set/2,1);
    for i=1:len_field2set
        tokens=textscan(label2set{i},'%s','Delimiter','_');
        tokens=tokens{1};
        if(length(tokens)==2)%var name
            loadfile=setfield(loadfile,label2set{i},cell(1,1));
        elseif (length(tokens)==1)%var data
            loadfile=setfield(loadfile,label2set{i},[]);
        else
            errordlg('readmatlogfile函数label2set读取错误！');
        end
    end
    %open a biggggggg buffer added by Anakin.Qin 20190325
    try
        if (len_fline<10000)
            for i=1:len_field2set/2
                data2set{i}=zeros(round(len_fline),var_lenset(i));
            end
        else
            for i=1:len_field2set/2
                data2set{i}=zeros(len_fline/buffsize_divd,var_lenset(i));
            end
        end
    catch
        fclose all;
        delete(hwaitbar);%close(hwaitbar);关闭读取的进度条，显示读取错误界面
        errordlg(lasterr,'缓存溢出错误，请增大缓存量允许值');
        rethrow(lasterror);
    end
    %set data value to the struct field from the flineread data
    %should we use parpool并行计算?isuse_parcalc
    isoverbuff=0;
    ptr=zeros(len_field2set/2,1);
    for i=1:len_fline
        tokens=textscan(flinedata{i},'%s','Delimiter',',');
        tokens=tokens{1};
        %         if strcmpi(tokens{1},'mode')
        %             fu=0;
        %         end
        if strcmp(tokens{1},'FMT')%write label
            if(isfield(loadfile,tokens{4}))
                %正常情况下的数据中不会出现重复的FMT格式定义
                len_valid_label=length(tokens)-4;%还要加上LineNo标签凑齐格式
                temp=cell(len_valid_label,1);
                temp{1}='LineNo';
                for j=2:len_valid_label
                    temp{j}=tokens{j+4};
                end
                loadfile=setfield(loadfile,strcat(tokens{4},'_label'),temp);
            end
        elseif(isfield(loadfile,tokens{1}))%write data
            %按照正常格式依顺序写进data中
            idx=idx_data2set(label2set,tokens{1});
            len_valid_label=length(tokens);%还要加上LineNo标签凑齐格式
            temp=zeros(1,len_valid_label);
            temp(1)=518;
            for j=2:len_valid_label
                temp(j)=apminfo_str2double(tokens{j});
            end
            [rlen,~]=size(data2set{idx});
            ptr(idx)=ptr(idx)+1;
            if(ptr(idx)<rlen)
                data2set{idx}(ptr(idx),:)=temp;
            else
                %the idx is larger than the data2set range
                data2set{idx}=[data2set{idx};zeros(1,len_valid_label)];
                data2set{idx}(ptr(idx),:)=temp;
                isoverbuff=1;
            end
            %add dim, we can use repmat or kron
            %data2set{idx}=repmat(data2set{idx},[rlen+1,1]);
            %data2set{idx}=kron([rlen+1,1],data2set{idx});
            %add a row
            %data2set{idx}=[data2set{idx};zeros(1,clen)];
        end
    end
    if(isoverbuff)
        warndlg('Modify the buff size divide num','Buff warning');
    end
    %删除ptr之外的无效空格，采用最便捷的直接取有效数据的方法
    temp=cell(len_field2set/2,1);
    for i=1:len_field2set/2
        if(ptr(i)~=0)
            temp{i}=data2set{i,1}(1:ptr(i),:);
        else
            %置空单元格
            temp{i}=[];
        end
    end
    data2set=temp;
    %检查data2set是否全部提取完毕，将所有不存在的变量按对应长度强制赋0
    %set var data to the struct
    for i=1:len_field2set/2
        if (isempty(data2set{i}))
            temp=label2set{i*2-1};
            temp=getfield(loadfile,temp);
            data2set{i}=zeros(1,length(temp));
        end
        loadfile=setfield(loadfile,label2set{i*2},data2set{i});
    end
    getallname=label2set;
else
    %% 读取mat格式文件
    whosdata = whos('-file',File{iFile});
    if strcmp(whosdata(1).name,'@')%去掉特殊标志符
        whosdata=whosdata(2:end);
    end
    getallname=cell(length(whosdata),1);
    for i=1:length(whosdata)
        getallname{i}=whosdata(i).name;
    end
    loadfile=load (File{iFile},getallname{:});
end
%% 开始数据读取
%读取配置文件，该文件写明了需要转换的变量，忽略不存在的变量
cfgname='Configuration_AnakinQin.cfg';
cfgfpath=strcat(rootpath,'\',cfgname);
fid=fopen(cfgfpath);
if fid==-1
    %未找到正确的配置文件
    fprintf('Cannot find "%s" file in path:<"%s">!!\n\n\n',cfgfpath,cfgname);
    errordlg('Cannot find ".cfg" file in root path');
    return;
end
flag=1;
while flag
    skip=fgetl(fid);
    tokens=textscan(skip,'%s','Delimiter','_');
    tokens=tokens{1};
    flag=~strcmp(tokens{1},'@@@');
end
for i=1:8
    fgetl(fid);
end
%时间单位选择
fgetl(fid);
temp=fscanf(fid,'%s',1);
if strcmpi(temp,'us')
    tmunit=1;
elseif strcmpi(temp,'ms')
    tmunit=1e-3;
elseif strcmpi(temp,'sec')
    tmunit=1e-6;
elseif strcmpi(temp,'min')
    tmunit=(1e-6)/60;
elseif strcmpi(temp,'hou')
    tmunit=(1e-6)/3600;
else
    errordlg('The time unit is incorrect in cfg file');
end
fgetl(fid);
fgetl(fid);
fgetl(fid);
numscan=fscanf(fid,'%f',1);
minussss=0;
scanset=cell(1,1);
t=1;
for i=1:numscan
    temp=fscanf(fid,'%s',1);
    if isvalidlabel(temp,getallname,loadfile)%寻找是否是正确的label标签
        scanset{t}=temp;
        t=t+1;
    else
        minussss=minussss+1;
    end
    %添加“//”用作强制终止读取的功能，但是要在指定读取变量个数之内才能起作用
    if i==numscan || strcmp(temp,'//')
        validscan=i;
        break;
    end
end
fclose(fid);
% len_labset=numscan-minussss;
len_labset=validscan-minussss;
labset=cell(len_labset,1);
% sort
scanset = mysort_dash(scanset);
stdtime_att=[];
stdtime_mode=[];
stdtime_ev=[];
stdtime_err=[];
stdtime_cmd=[];
for i=1:len_labset
    labset{i}=scanset{i};
    %顺便记录下作为标准时间度量单位的序号指针
    if strcmpi('att',labset{i}(1:length(labset{i})-6))
        stdtime_att = i;
    end
    if strcmpi('mode',labset{i}(1:length(labset{i})-6))
        stdtime_mode = i;
    end
    if strcmpi('ev',labset{i}(1:length(labset{i})-6))
        stdtime_ev = i;
    end
    if strcmpi('err',labset{i}(1:length(labset{i})-6))
        stdtime_err = i;
    end
    if strcmpi('cmd',labset{i}(1:length(labset{i})-6))
        stdtime_cmd = i;
    end
end
scanset=[];%release load
%获取所需要转换的变量名称
% labset={'ATT_label','BAR2_label','BARO_label','CTRL_label','CTUN_label','GPS_label','IMU_label','IMU2_label','IMU3_label','MAG_label','MAG2_label','MAG3_label','NKF1_label','NKF6_label',...
%     'NTUN_label','POS_label','RCIN_label','RCOU_label','TERR_label'};
%len_labset=length(labset);%无需重复计算
sigt=zeros(len_labset,1);
len_sig=zeros(len_labset,1);
timeset=cell(len_labset,1);
nstr=cell(len_labset,1);
for i=1:len_labset
    temp=getfield(loadfile,labset{i});%读取loadfile中的变量
    lentemp=length(temp);
    num=0;
    for j=1:lentemp
        if(~strcmp(temp{j},'LineNo') && ~strcmp(temp{j},'TimeUS'))
            num= num+1;
            if isempty(nstr{i})
                nstr{i}=strcat(labset{i}(1:length(labset{i})-5),temp{j});%label
            else
                nstr{i}=strcat(nstr{i},',',labset{i}(1:length(labset{i})-5),temp{j});%label
            end
        else
            sigt(i)=sigt(i)+1;
        end
    end
    tokens=textscan(nstr{i},'%s','Delimiter',',');
    nstr{i}=tokens{1};
    len_sig(i)=num;
end
len_sum=0;
for i=1:length(len_sig)
    len_sum=len_sum+len_sig(i);
end

%读取所有变量对应的数值
dataset=cell(len_sum,1);
t=1;
for i=1:len_labset
    vstr=getfield(loadfile,labset{i}(1:length(labset{i})-6));
    for j=1:len_sig(i)
        dataset{t}=vstr(:,j+sigt(i));
        t=t+1;
    end
end
log_tm=cell(len_labset,1);
log_feq=zeros(len_labset,1);%记录数据频率
%获取时间戳，添加不同速率组时间数据，完成单位统一到配置文件中去，通常单位是sec秒
for i=1:len_labset
    temp=getfield(loadfile,labset{i}(1:length(labset{i})-6));
    timeset{i}=temp(:,2);%正常情况时间计数器都在第二列数据
end
t_init = findstart_time(timeset);%时间计数器初始位;每个速率组数据记录起始标准并不一致，需要找一个最小的值
for i=1:len_labset
    for j=1:length(timeset{i})
        if j==1
            %t_init=timeset{i}(1);
            temp=timeset{i}(1);
        else
            temp1=timeset{i}(j)-temp;
            temp=timeset{i}(j);
            log_tm{i}(j)=temp1;
        end
        %timeset{i}(j)=(timeset{i}(j)-t_init)*tmunit;%并非非要将
        timeset{i}(j)=(timeset{i}(j)-0)*tmunit;
    end
end
%求各个数据之间的时间差，求出数据记录的平均频率
temp=0;
for i=1:len_labset
    for j=1:length(log_tm{i})
        temp=temp+log_tm{i}(j);
    end
    temp=temp/length(log_tm{i})*(1e-6);
    log_feq(i)=findnerstfeq(temp);
end
%记录每个变量的起始指针
tnulab=zeros(len_labset,1);%labset;
tnulab(1)=1;
for i=2:len_labset
    tnulab(i)=tnulab(i-1)+len_sig(i-1)+1;%时间数据堆积到一起的
end
%单独处理MODE_label和EV_label和CMD_label标签下的数据文件，两者几乎属于触发式记录，会导致数据过于狭窄，画图处理时显示效果为折线形式，不满足使用要求
%MODE_label指代飞机所处的飞行模态mode，EV_label记录了飞机飞行过程中的触发的事件event记录,cmd
%这里折衷考虑将mode和ev的数据都直接用10hz的频率扩展成长数据集,最后一帧取最大时间帧
spe_freq = 10;
spe_dt = 1/spe_freq*(tmunit/1.0e-06);%统一指定的特殊单位到配置文件中去
%stdtime_max = max(stdtime_att,stdtime_mode,stdtime_ev);
stdtime_max = stdtime_att;
if(~isempty(stdtime_mode))
    if timeset{stdtime_mode}(end)>timeset{stdtime_max}(end)
        stdtime_max = stdtime_mode;
    end
end
if(~isempty(stdtime_ev))
    if timeset{stdtime_ev}(end)>timeset{stdtime_max}(end)
        stdtime_max = stdtime_ev;
    end
end
if(~isempty(stdtime_err))
    if timeset{stdtime_err}(end)>timeset{stdtime_max}(end)
        stdtime_max = stdtime_err;
    end
end
if(~isempty(stdtime_cmd))
    if timeset{stdtime_cmd}(end)>timeset{stdtime_max}(end)
        stdtime_max = stdtime_cmd;
    end
end
lasttime_stamp=timeset{stdtime_max}(end);
for i=1:len_labset
    if (strcmpi('mode',labset{i}(1:length(labset{i})-6)) || strcmpi('ev',labset{i}(1:length(labset{i})-6)) ||...
        strcmpi('err',labset{i}(1:length(labset{i})-6)) || strcmpi('cmd',labset{i}(1:length(labset{i})-6)))
        time_spe = timeset{i};%原始时间节点
        data_spe = cell(len_sig(i),1);
        %确定数值指针
        if i==1
            dataptr = 1;
        else
            dataptr = 1;
            for j=1:i-1
                dataptr = dataptr+len_sig(j);
            end
        end
        for j=1:len_sig(i)
            data_spe{j} = dataset{dataptr+j-1};%原始数值节点数据
        end
        time_seq_should = (0:spe_dt:(lasttime_stamp+spe_dt*10))';%造一列约定频率的时间序列,将时间数往外扩充10格，防止末尾记录的截止数据引发挤兑
        data_seq_should = zeros(length(time_seq_should),1);%造一列对应的数值序列
        [timeset{i},temp_data] = my_interp1_should(time_spe,time_seq_should,data_spe,data_seq_should);
        %融合数据
        for j=1:len_sig(i)
            dataset{dataptr+j-1}=[];
            dataset{dataptr+j-1}=temp_data{j};
        end
    end
end
clearvars -except timeset dataset tnulab log_feq;
end


function [timeset,temp_data] = my_interp1_should(time_spe,time_seq_should,data_spe,data_seq_should)
delta_t=time_seq_should(2)-time_seq_should(1);
len_ind=length(time_spe);
len=length(time_seq_should);
len_temp=length(data_spe);
timeset=time_seq_should;%初始化时间数据集
temp_data=cell(len_temp,1);
for i=1:len_temp
    temp_data{i}=data_seq_should;
end
spe_index=zeros(len_ind,1);
% spe_index=findrgtind(time_spe,time_seq_should);
for i=1:len_ind
    for j=1:len
        dt0=abs(time_spe(i)-time_seq_should(j));
        %if abs(delta_t-dt0)<delta_t
        if dt0<delta_t
            spe_index(i)=j;
            if i~=1%将相同的索引位置往后错开
                if spe_index(i)==spe_index(i-1)
                    spe_index(i) = spe_index(i)+1;
                end
            end
            break;
        end
    end
end
% %检测数据是否相同长度，并重新初始化输出量
% if spe_index(end)>len
%
% end
%集成时间数据
for i=1:len_ind
    timeset(spe_index(i))=time_spe(i);
end
%集成数值数据
for j=1:len_temp
    for i=1:len_ind-1
        temp_data{j}(spe_index(i):spe_index(i+1)-1) = data_spe{j}(i);
    end
    temp_data{j}(spe_index(len_ind):end) = data_spe{j}(len_ind);
end
end

% function spe_index=findrgtind(time_spe,time_seq_should)
%
%
% end

function y = findstart_time(timeset)
len = length(timeset);
temp = zeros(len,1);
for i=1:len
    temp(i) = timeset{i}(1);
end
% [y,ind] = min(temp);
y = min(temp);
end


function feq=findnerstfeq(T_inp)
%总共有以下频率：400hz,200hz,100hz,50hz,25hz,20hz,10hz,5hz,3.3hz,3hz,1hz,0.1hz
hzset=[400;200;100;50;25;20;10;5;3.3;3;1;0.1];
hz=1/T_inp;
delta=zeros(12,1);
for i=1:12
    delta(i)=abs(hzset(i)-hz);
end
[~,ind]=min(delta);
feq=hzset(ind);
clearvars -except feq;
end