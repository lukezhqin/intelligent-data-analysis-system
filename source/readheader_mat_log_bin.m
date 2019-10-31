function [nvar,varlist,alllist]=readheader_mat_log_bin(File)
% Copyright @XXX 2017-2019 All Rights Reserved.#
% Author   : Luke.Qin  2017.12.26 11:16:24     #
% Website  : https://lukezhqin.github.io       #
% E-mail   : zonghang.qin@foxmail.com          #
% Intelligent Data Analysis System(IDAS)
rootpath=pwd;
%% 导入数据,并读取配置文件
if ~ischar(File)
    fprintf('选择的文件不正确\n');
    return;%暂时未添加多文件选择，只能单个文件处理
end
%% 读取log格式文件
%分离后缀
% [pathstr, name, ext] = fileparts(File);
[~, ~, ext] = fileparts(File);
if (strcmpi(ext,'.bin'))
    %% 读取数据头bin格式
    fid = fopen(File);
    if (fid==-1)
        errordlg('文件系统严重错误！');
        return;
    end
    freaddata=fread(fid);
    fclose(fid);
    errordlg('not enough magic energy,not yet finished');
    return;
    % to handle the freaddata format according to A3 98
    %freaddata_hex=dec2hex(freaddata);
end
if (strcmpi(ext,'.log'))
    %暂时还未整理好bin文件读取:a=fread(fid)直接读取二进制文件，但是需要知道数据协议，等待2.0版本进行发布bin文件直接读取功能--->89一行数据
    %读取配置文件，该文件写明了需要转换的变量，忽略不存在的变量
    cfgname='Configuration_LukeQin.cfg';
    cfgfpath=strcat(rootpath,'\',cfgname);
    fid=fopen(cfgfpath);
    if fid==-1
        %未找到正确的配置文件
        fprintf('Cannot find "%s" file in path:<"%s">!!\n\n\n',cfgfpath,cfgname);
        errordlg('Cannot find ".cfg" file in root path');
        return;
    end
    flag=1;
    i=0;
    while flag
        skip=fgetl(fid);
        tokens=textscan(skip,'%s','Delimiter','_');
        tokens=tokens{1};
        flag=~strcmp(tokens{1},'@@@');
        i=i+1;
        if i>1000
            fprintf('The cfg file is incorrect.\n');
            fclose(fid);
            return;
        end
    end
    for i=1:10
        fgetl(fid);
    end
    %时间单位选择
    fgetl(fid);
    tmunit=fscanf(fid,'%s',1);%default:sec
    fgetl(fid);
    fgetl(fid);
    fgetl(fid);
    numscan=fscanf(fid,'%f',1);
    fuck=cell(1,numscan);
    scanset=cell(2,2);
    %添加“//”控制读取末尾的功能，与行数功能相融合。首先按给定行数读取，但是一旦读到停止符“//”即可停止。
    for i=1:numscan
        temp=fscanf(fid,'%s',1);
        %添加“//”用作强制终止读取的功能，但是要在指定读取变量个数之内才能起作用
        if i==numscan || strcmp(temp,'//')
            break;
        else
            fuck{i}=temp;
        end
    end
    fclose(fid);
    %去掉'_label'标签字节
    %同时还需要探测是否有标志_MRK
    t=1;
    for i=1:numscan
        if ~isempty(fuck{i})
            temp=textscan(fuck{i},'%s','Delimiter','_');
            temp=temp{1};
            scanset{t,1}=temp{1};
            if (length(temp)==3)
                %use marker later in plot
                if (strcmpi(temp{3},'MRK'))
                    scanset{t,2}=1;
                else
                    scanset{t,2}=0;
                end
            else
                scanset{t,2}=0;
            end
            t=t+1;
        end
    end
    fuck=[];
    temp=size(scanset);
    scanset_len=temp(1);
    temp=[];
    
    %% 读取数据头log格式
    fid = fopen(File);
    if (fid==-1)
        errordlg('Corruption in file system！');
        return;
    end
    %tic;
    flinelist=cell(2,1);
    textscandata=textscan(fid,'%s','Delimiter','\n');
    textscandata=textscandata{1};
    fclose(fid);
    len_flinedata=length(textscandata);
    t=1;
    for i=1:len_flinedata
        tokens=textscan(textscandata{i},'%s','Delimiter',',');
        tokens=tokens{1};
        if (strcmp('FMT',tokens{1}) && ~strcmp('FMT',tokens(4)))
            flinelist{t}=textscandata{i};
            t=t+1;
        end
    end
    %get alllist aparted and sorted here
    [alllist,valid_scanset,len_sig,ptr_sig]=myapartedsortcheck(flinelist,scanset(:,1));
    minussss=scanset_len-valid_scanset;
    %toc;
    %
    %
    %去掉所有找不到的数据标签
    if (minussss~=0)
        scanset_final=cell(valid_scanset,2);
        temp1=zeros(valid_scanset,1);
        temp2=zeros(valid_scanset,1);
        k=1;
        for i=1:scanset_len
            if (len_sig(i)~=0)
                scanset_final{k,1}=scanset{i,1};
                scanset_final{k,2}=scanset{i,2};
                temp1(k)=len_sig(i);
                temp2(k)=ptr_sig(i);
                k=k+1;
            else
                %提示有那几个标签不存在，不存在的数据标签不利于数据对比分析。
                str_war=strcat('Data label: ',scanset{i,1},'_label is NOT exist!');
                warndlg(str_war,'数据标签缺失');
            end
        end
        len_sig=[];
        ptr_sig=[];
        scanset=[];
        scanset=scanset_final;
        scanset_final=[];
        len_sig=temp1;
        ptr_sig=temp2;
    end
    %从所求指针中读取配置文件中的匹配标签数据
    nvar=0;
    varlist=cell(2,2);
    temp=1;
    for i=1:valid_scanset
        nownum=len_sig(i);
        nvar=nvar+nownum;
        tokens=textscan(flinelist{ptr_sig(i)},'%s','Delimiter',',');
        tokens=tokens{1};
        start_cnt=length(tokens)-nownum+1;
        for j=1:nownum
            varlist{temp,1}=strcat(scanset{i,1},'_',tokens{start_cnt});
            varlist{temp,2}=scanset{i,2};
            start_cnt=start_cnt+1;
            temp=temp+1;
        end
    end
    %sort the data label
    varlist = mysort_dash(varlist);
    clearvars -except nvar varlist alllist
    return;
end
%% 读取mat格式文件---20190728今后放弃维护该格式文件的读取，直接读取bin文件
whosdata = whos('-file',File);
if strcmp(whosdata(1).name,'@')%去掉特殊标志符
    whosdata=whosdata(2:end);
end
getallname=cell(length(whosdata),1);
for i=1:length(whosdata)
    getallname{i}=whosdata(i).name;
end
whosdata=[];%释放内存
loadfile=load(File,getallname{:});
%读取配置文件，该文件写明了需要转换的变量，忽略不存在的变量
cfgname='Configuration_LukeQin.cfg';
cfgfpath=strcat(rootpath,'\',cfgname);
fid=fopen(cfgfpath);
if fid==-1
    %未找到正确的配置文件
    fprintf('Cannot find "%s" file in path:<"%s">!!\n\n\n',cfgfpath,cfgname);
    errordlg('Cannot find ".cfg" file in root path');
    return;
end
flag=1;
i=0;
while flag
    skip=fgetl(fid);
    tokens=textscan(skip,'%s','Delimiter','_');
    tokens=tokens{1};
    flag=~strcmp(tokens{1},'@@@');
    i=i+1;
    if i>1000
        fprintf('The cfg file is incorrect.\n');
        fclose(fid);
        return;
    end
end
for i=1:10
    fgetl(fid);
end
%时间单位选择
fgetl(fid);
% tmunit=fscanf(fid,'%s',1);
fgetl(fid);
fgetl(fid);
fgetl(fid);
numscan=fscanf(fid,'%f',1);
minussss=0;
scanset=cell(1,numscan);
%添加“//”控制读取末尾的功能，与行数功能相融合。首先按给定行数读取，但是一旦读到停止符“//”即可停止。
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
% len_labset = numscan-minussss;
len_labset = validscan-minussss;%用validscan替代原大额的numscan
labset=cell(1,len_labset);
for i=1:len_labset
    labset{i}=scanset{i};
end
scanset = [];%release load
%% 获取所需要转换的变量名称
% labset={'ATT_label','BAR2_label','BARO_label','CTRL_label','CTUN_label','GPS_label','IMU_label','IMU2_label','IMU3_label','MAG_label','MAG2_label','MAG3_label','NKF1_label','NKF6_label',...
%     'NTUN_label','POS_label','RCIN_label','RCOU_label','TERR_label'};
len_sig=zeros(len_labset,1);
nstr=cell(len_labset,1);
for i=1:len_labset
    %     temp=(eval(labset{i}));
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
        end
    end
    tokens=textscan(nstr{i},'%s','Delimiter',',');
    nstr{i}=tokens{1};
    len_sig(i)=num;
end
loadfile = [];%释放内存
nvar=0;
for i=1:length(len_sig)
    nvar=nvar+len_sig(i);
end
varlist=cell(nvar,1);
t=1;
for i=1:len_labset
    %t=t+1;%留出时间标签
    for j=1:len_sig(i)
        if ~isempty(nstr{i}{j})
            varlist{t}=nstr{i}{j};
            t=t+1;
        end
    end
end
%sort the data label
varlist = mysort_dash(varlist);
% clear temp len_sig getallname;
clearvars -except nvar varlist alllist
end

function [y,valid_scanset,len_sig,ptr_sig]=myapartedsortcheck(x,rq)
%apart the x and get it sorted
valid_scanset=0;
rq_len=length(rq);
len_sig=zeros(rq_len,1);
ptr_sig=zeros(rq_len,1);
tlen_sig=zeros(rq_len,1);
tptr_sig=zeros(rq_len,1);
lenx=length(x);
t=cell(2,1);
ff=0;
% for kk=1:rq_len
%     for i=1:lenx
%         tokens=textscan(x{i},'%s','Delimiter',',');
%         tokens=tokens{1};
%         %有几个参数不需要进行数据绘图
%         if (~strcmp(tokens{4},'UNIT') && ...
%                 ~strcmp(tokens{4},'FMTU') && ...
%                 ~strcmp(tokens{4},'MULT') && ...
%                 ~strcmp(tokens{4},'PARM'))
%         end
%     end
% end
%
for i=1:lenx
    tokens=textscan(x{i},'%s','Delimiter',',');
    tokens=tokens{1};
    %有几个参数不需要进行数据绘图
    if (~strcmp(tokens{4},'UNIT') && ...
            ~strcmp(tokens{4},'FMTU') && ...
            ~strcmp(tokens{4},'MULT') && ...
            ~strcmp(tokens{4},'PARM'))
        ff=ff+1;
        t{ff}=tokens{4};
        for kk=1:rq_len
            if strcmp(t{ff},rq{kk})
                if kk==1
                    a=1;
                end
                tlen_sig(kk)=length(tokens)-6;
                tptr_sig(kk)=i;
                valid_scanset=valid_scanset+1;
            end
        end
    end
end
y=cell(ff,1);
%be very careful about the following sort method and prt location
[~,idx]=sort(t);
for i=1:ff
    y{i}=t{idx(i)};
end
len_sig=tlen_sig;
ptr_sig=tptr_sig;
%the following process is designed to track the y params sequence, but we
%still need all the information in x.
% for i=1:rq_len
%     if (tlen_sig(i)~=0 && tptr_sig(i)~=0)
%         len_sig(i)=idx(tlen_sig(i));
%         ptr_sig(i)=idx(tptr_sig(i));
%     end
% end
end

function y=mysort_dash(x)
%only to sort the char before the dash signal "_"
temp=size(x);
lenx=temp(1);
y=cell(lenx,temp(2));
t=cell(lenx,1);
for i=1:lenx
    tokens=textscan(x{i,1},'%s','Delimiter','_');
    tokens=tokens{1};
    t{i}=tokens{1};
end
[~,idx]=sort(t);
for i=1:lenx
    for j=1:temp(2)
        y{i,j}=x{idx(i),j};
    end
end
end

function [valid_scanset,len_sig,ptr_sig]=findchecklabel(alldata,scanset)
alldata_len=length(alldata);
scanset_len=length(scanset);
len_sig=zeros(scanset_len,1);
ptr_sig=zeros(scanset_len,1);
%FMT, 128, 89, FMT, BBnNZ, Type,Length,Name,Format,Columns
%fuck the first line
valid_scanset=0;
i=1;
while (i<=alldata_len)
    tokens=textscan(alldata{i},'%s','Delimiter',',');
    tokens=tokens{1};
    if (strcmp('FMT',tokens{1}))
        for j=1:scanset_len
            if (strcmp(scanset{j},tokens{4}))
                valid_scanset=valid_scanset+1;
                len_sig(j)=length(tokens)-6;
                ptr_sig(j)=i;
                break;
            end
        end
    end
    i=i+1;
end

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

%strtrim: Remove leading and trailing whitespace from string
%whitespace: Use the whitespace  as delimiter to preserve leading and trailing spaces in a string