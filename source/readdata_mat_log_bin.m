function idasdata=readdata_mat_log_bin(File,varlist)
% Copyright @XXX 2017-2019 All Rights Reserved.#
% Author   : Anakin.Qin  2017.12.26 11:16:24   #
% Website  : https://anakinqin.github.io       #
% E-mail   : zonghang.qin@foxmail.com          #
% Intelligent Data Analysis System(IDAS)
%�ⲿ���ڰ����з���fread����ʱ���Կ��ǲ��ò��м���
%% ��ʾ������
SizeofFile=0;
newfileinfo=cell(length(File),1);
for i=1:length(File)
    newfileinfo{i} = dir(File{i});
    SizeofFile=SizeofFile+newfileinfo{i}.bytes;
end
% TimeToRead=SizeofFile/139699962*4;% ��ȡ137MB���ݴ��Ҫ4s
TimeToRead=SizeofFile/139699962*6;%��΢�����ʱ����
strDisp='';
strName=sprintf('���ݶ�ȡ�У�Լ��ʱ%ds',round(TimeToRead));
hwaitbar = waitbar(0,strDisp,'Name',strName);
set(get(get(hwaitbar,'Children'),'Title'),'Interpreter','none'); % waitbarʵ������һ��figure��strDisp���ڵ�'message'������axes�ı���
%% ��ȡ����
if ~iscell(File)
    File={File};
end
nfile=length(File);
nvar=length(varlist);
idasdata=repmat([],nfile);
try
    for iFile=1:nfile
        [pathstr, name, ext] = fileparts(File{iFile});
        strDisp=['��ȡ' name ext,' ...'];
        waitbar((iFile-1)/nfile,hwaitbar,strDisp)
        idasdata{iFile}.File=File{iFile};
        idasdata{iFile}.varlist=varlist;%��ȡmat/log��ʽ�ļ�
        [idasdata{iFile}.Time,idasdata{iFile}.Data,idasdata{iFile}.label,idasdata{iFile}.logfeq]=readmatlogfile(File,iFile,varlist);
        waitbar(iFile/nfile,hwaitbar,strDisp)
    end
catch
    fclose all;
    delete(hwaitbar);%close(hwaitbar);�رն�ȡ�Ľ���������ʾ��ȡ�������
    errordlg(lasterr,'�ļ���ȡ����');
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
        fprintf('�Ҳ������ݡ�%s��.\n',x);
    end
    %rethrow(ce)%ȥ�������ݱ�ǩ
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
%ע��label_2����˫����ǩ
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


function [timeset,dataset,tnulab,log_feq]=readmatlogfile(File,iFile,varlist)
rootpath=pwd;
[~, ~, ext] = fileparts(File{iFile});
if (strcmpi(ext,'.log'))
    %% ��ȡlog��ʽ�ļ�
    %��ȡ�����ļ������ļ�д������Ҫת���ı��������Բ����ڵı���
    %��ȡ�Ƿ���Ҫ���ò��м�����Զ���ѡ��
    cfgname='Configuration_LukeQin.cfg';
    cfgfpath=strcat(rootpath,'\',cfgname);
    fid=fopen(cfgfpath);
    if fid==-1
        %δ�ҵ���ȷ�������ļ�
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
    %�������ļ���ȡ�Ƿ���Ҫ�������г�
    isuse_parcalc=logical(str2double(fgetl(fid)));
    %���������µ���С������Ĭ��ȫ�����棬���������ڴ����ʱ�����޸ļ��ɣ�����Ϊ��������������ֵԽ�󣬻�����������Ч��Խǿ��
    fgetl(fid);
    buffsize_divd=round(str2double(fgetl(fid)));
    if(buffsize_divd<1)
        buffsize_divd=1;
    end
    fclose(fid);
    %���ݶ�ȡ
    fid = fopen(File{iFile});
    if (fid==-1)
        errordlg('Corruption in file system��');
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
            errordlg('readmatlogfile����label2set��ȡ����');
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
        delete(hwaitbar);%close(hwaitbar);�رն�ȡ�Ľ���������ʾ��ȡ�������
        errordlg(lasterr,'����������������󻺴�������ֵ');
        rethrow(lasterror);
    end
    %set data value to the struct field from the flineread data
    %should we use parpool���м���?isuse_parcalc
    isoverbuff=0;
    ptr=zeros(len_field2set/2,1);
    for i=1:len_fline
        tokens=textscan(flinedata{i},'%s','Delimiter',',');
        tokens=tokens{1};
        if strcmp(tokens{1},'FMT')%write label
            if(isfield(loadfile,tokens{4}))
                %��������µ������в�������ظ���FMT��ʽ����
                len_valid_label=length(tokens)-4;%��Ҫ����LineNo��ǩ�����ʽ
                temp=cell(len_valid_label,1);
                temp{1}='LineNo';
                for j=2:len_valid_label
                    temp{j}=tokens{j+4};
                end
                loadfile=setfield(loadfile,strcat(tokens{4},'_label'),temp);
            end
        elseif(isfield(loadfile,tokens{1}))%write data
            %����������ʽ��˳��д��data��
            idx=idx_data2set(label2set,tokens{1});
            len_valid_label=length(tokens);%��Ҫ����LineNo��ǩ�����ʽ
            temp=zeros(1,len_valid_label);
            temp(1)=518;
            for j=2:len_valid_label
                temp(j)=str2double(tokens{j});
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
    %ɾ��ptr֮�����Ч�ո񣬲������ݵ�ֱ��ȡ��Ч���ݵķ���
    temp=cell(len_field2set/2,1);
    for i=1:len_field2set/2
        if(ptr(i)~=0)
            temp{i}=data2set{i,1}(1:ptr(i),:);
        else
            %�ÿյ�Ԫ��
            temp{i}=[];
        end
    end
    data2set=temp;
    %���data2set�Ƿ�ȫ����ȡ��ϣ������в����ڵı�������Ӧ����ǿ�Ƹ�0
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
    %% ��ȡmat��ʽ�ļ�
    whosdata = whos('-file',File{iFile});
    if strcmp(whosdata(1).name,'@')%ȥ�������־��
        whosdata=whosdata(2:end);
    end
    getallname=cell(length(whosdata),1);
    for i=1:length(whosdata)
        getallname{i}=whosdata(i).name;
    end
    loadfile=load (File{iFile},getallname{:});
end
%% ��ʼ���ݶ�ȡ
%��ȡ�����ļ������ļ�д������Ҫת���ı��������Բ����ڵı���
cfgname='Configuration_LukeQin.cfg';
cfgfpath=strcat(rootpath,'\',cfgname);
fid=fopen(cfgfpath);
if fid==-1
    %δ�ҵ���ȷ�������ļ�
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
%ʱ�䵥λѡ��
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
    if isvalidlabel(temp,getallname,loadfile)%Ѱ���Ƿ�����ȷ��label��ǩ
        scanset{t}=temp;
        t=t+1;
    else
        minussss=minussss+1;
    end
    %��ӡ�//������ǿ����ֹ��ȡ�Ĺ��ܣ�����Ҫ��ָ����ȡ��������֮�ڲ���������
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
for i=1:len_labset
    labset{i}=scanset{i};
    %˳���¼����Ϊ��׼ʱ�������λ�����ָ��
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
end
scanset=[];%release load
%��ȡ����Ҫת���ı�������
% labset={'ATT_label','BAR2_label','BARO_label','CTRL_label','CTUN_label','GPS_label','IMU_label','IMU2_label','IMU3_label','MAG_label','MAG2_label','MAG3_label','NKF1_label','NKF6_label',...
%     'NTUN_label','POS_label','RCIN_label','RCOU_label','TERR_label'};
%len_labset=length(labset);%�����ظ�����
sigt=zeros(len_labset,1);
len_sig=zeros(len_labset,1);
timeset=cell(len_labset,1);
nstr=cell(len_labset,1);
for i=1:len_labset
    temp=getfield(loadfile,labset{i});%��ȡloadfile�еı���
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

%��ȡ���б�����Ӧ����ֵ
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
log_feq=zeros(len_labset,1);%��¼����Ƶ��
%��ȡʱ�������Ӳ�ͬ������ʱ�����ݣ���ɵ�λͳһ�������ļ���ȥ��ͨ����λ��sec��
for i=1:len_labset
    temp=getfield(loadfile,labset{i}(1:length(labset{i})-6));
    timeset{i}=temp(:,2);%�������ʱ����������ڵڶ�������
end
t_init = findstart_time(timeset);%ʱ���������ʼλ;ÿ�����������ݼ�¼��ʼ��׼����һ�£���Ҫ��һ����С��ֵ
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
        %timeset{i}(j)=(timeset{i}(j)-t_init)*tmunit;%���Ƿ�Ҫ��
        timeset{i}(j)=(timeset{i}(j)-0)*tmunit;
    end
end
%���������֮���ʱ��������ݼ�¼��ƽ��Ƶ��
temp=0;
for i=1:len_labset
    for j=1:length(log_tm{i})
        temp=temp+log_tm{i}(j);
    end
    temp=temp/length(log_tm{i})*(1e-6);
    log_feq(i)=findnerstfeq(temp);
end
%��¼ÿ����������ʼָ��
tnulab=zeros(len_labset,1);%labset;
tnulab(1)=1;
for i=2:len_labset
    tnulab(i)=tnulab(i-1)+len_sig(i-1)+1;%ʱ�����ݶѻ���һ���
end
%��������MODE_label��EV_label��ǩ�µ������ļ������߼������ڴ���ʽ��¼���ᵼ�����ݹ�����խ����ͼ����ʱ��ʾЧ��Ϊ������ʽ��������ʹ��Ҫ��
%MODE_labelָ���ɻ������ķ���ģ̬mode��EV_label��¼�˷ɻ����й����еĴ������¼�event��¼
%�������Կ��ǽ�mode��ev�����ݶ�ֱ����10hz��Ƶ����չ�ɳ����ݼ�,���һ֡ȡ���ʱ��֡
spe_freq = 10;
spe_dt = 1/spe_freq*(tmunit/1.0e-06);%ͳһָ�������ⵥλ�������ļ���ȥ
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
lasttime_stamp=timeset{stdtime_max}(end);
for i=1:len_labset
    if strcmpi('mode',labset{i}(1:length(labset{i})-6)) || strcmpi('ev',labset{i}(1:length(labset{i})-6)) || strcmpi('err',labset{i}(1:length(labset{i})-6))
        time_spe = timeset{i};%ԭʼʱ��ڵ�
        data_spe = cell(len_sig(i),1);
        %ȷ����ֵָ��
        if i==1
            dataptr = 1;
        else
            dataptr = 1;
            for j=1:i-1
                dataptr = dataptr+len_sig(j);
            end
        end
        for j=1:len_sig(i)
            data_spe{j} = dataset{dataptr+j-1};%ԭʼ��ֵ�ڵ�����
        end
        time_seq_should = (0:spe_dt:(lasttime_stamp+spe_dt*10))';%��һ��Լ��Ƶ�ʵ�ʱ������,��ʱ������������10�񣬷�ֹĩβ��¼�Ľ�ֹ������������
        data_seq_should = zeros(length(time_seq_should),1);%��һ�ж�Ӧ����ֵ����
        [timeset{i},temp_data] = my_interp1_should(time_spe,time_seq_should,data_spe,data_seq_should);
        %�ں�����
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
timeset=time_seq_should;%��ʼ��ʱ�����ݼ�
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
            if i~=1%����ͬ������λ�������
                if spe_index(i)==spe_index(i-1)
                    spe_index(i) = spe_index(i)+1;
                end
            end
            break;
        end
    end
end
% %��������Ƿ���ͬ���ȣ������³�ʼ�������
% if spe_index(end)>len
%
% end
%����ʱ������
for i=1:len_ind
    timeset(spe_index(i))=time_spe(i);
end
%������ֵ����
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
%�ܹ�������Ƶ�ʣ�400hz,200hz,100hz,50hz,25hz,20hz,10hz,5hz,3.3hz,3hz,1hz,0.1hz
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