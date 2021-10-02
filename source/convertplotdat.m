%% ========================================
% Copyright @XXX 2017-2019 All Rights Reserved.#
% Author   : Anakin.Qin  2017.12.26 11:16:24   #
% Website  : https://anakinqin.github.io       #
% E-mail   : zonghang.qin@foxmail.com          #
% Intelligent Data Analysis System(IDAS)
% This file is used to convert the mat formating file to the dat file
% We don't use this method any more in this software.
function convertplotdat(FileName,PathName)
appdir=pwd;
%% ��������,����ȡ�����ļ�
if isempty(FileName) || isempty(PathName)
    [FileName,PathName] = uigetfile({'*.mat'},'Select the data files to plot','MultiSelect', 'on');
end
if ischar(FileName);
    filedir=[PathName,FileName];
else
    return;        %��ʱδ��Ӷ��ļ�ѡ��ֻ�ܵ����ļ�����
end
s = whos('-file',filedir);
whosdata = whos('-file',filedir);
if strcmp(whosdata(1).name,'@')%ȥ�������־��
    whosdata=whosdata(2:end);
end
getallname=cell(length(whosdata),1);
for i=1:length(whosdata)
    getallname{i}=whosdata(i).name;
end
loadfile=load (filedir,getallname{:});
%��ȡ�����ļ������ļ�д������Ҫת���ı��������Բ����ڵı���
cfgname='Configuration_LukeQin.cfg';
cfgfpath=strcat(appdir,'\',cfgname);
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
%ʱ�䵥λѡ��
fgetl(fid);
% tmunit=fscanf(fid,'%s',1);
fgetl(fid);
fgetl(fid);
fgetl(fid);
numscan=fscanf(fid,'%f',1);
minussss=0;
scanset=cell(1,numscan);
t=1;
for i=1:numscan
    temp=fscanf(fid,'%s',1);
    if isrgtlabel(temp,getallname)%Ѱ���Ƿ�����ȷ��label��ǩ
        scanset{t}=temp;
        t=t+1;
    else
        minussss=minussss+1;
    end
end
fclose(fid);
len_labset=numscan-minussss;
labset=cell(1,len_labset);
for i=1:len_labset
    labset{i}=scanset{i};
end
%% ��ȡ����Ҫת���ı�������
% labset={'ATT_label','BAR2_label','BARO_label','CTRL_label','CTUN_label','GPS_label','IMU_label','IMU2_label','IMU3_label','MAG_label','MAG2_label','MAG3_label','NKF1_label','NKF6_label',...
%     'NTUN_label','POS_label','RCIN_label','RCOU_label','TERR_label'};
% len_labset=length(labset);
sigt=zeros(len_labset,1);
len_sig=zeros(len_labset,1);
cntset_tname=cell(len_labset,1);
cntset_tdata=cell(len_labset,1);
nstr=cell(len_labset,1);
for i=1:len_labset
    %     temp=(eval(labset{i}));
    temp=getfield(loadfile,labset{i});%��ȡloadfile�еı���
    lentemp=length(temp);
    num=0;
    
    for j=1:lentemp
        %if(~isstrsame(temp{j},'LineNo') && ~isstrsame(temp{j},'TimeUS'))
        %������д����strcmp��strcmpiǰ���ϸ�Ƚϴ�Сд�����ߺ��Դ�Сд��Ϊmatlab��inline����
        if(~strcmp(temp{j},'LineNo') && ~strcmp(temp{j},'TimeUS'))
            num= num+1;
            if isempty(nstr{i})
                nstr{i}=strcat(labset{i}(1:length(labset{i})-5),temp{j});%label
            else
                nstr{i}=strcat(nstr{i},',',labset{i}(1:length(labset{i})-5),temp{j});%label
            end
            %sz=size(getfield(loadfile,labset{i}(1:length(labset{i})-6)));
            %valset.(eval(nstr))=zeros(sz(1),1);
            %valset=struct(nstr,zeros(sz(1),1));
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
namestr=cell(len_sum+length(len_sig),1);
t=1;
for i=1:len_labset
    t=t+1;%����ʱ���ǩ
    for j=1:len_sig(i)
        if ~isempty(nstr{i}{j})
            namestr{t}=nstr{i}{j};
            t=t+1;
        end
    end
end
t=1;
for i=1:(length(namestr)-1)
    %���ղ�ͬ�����������Ե�ʱ�������
    if isempty(namestr{i})
        tokens=textscan(namestr{i+1},'%s','Delimiter','_');
        cntset_tname{t}=tokens{1}{1};
        namestr{i}=strcat('t_',cntset_tname{t});%ʱ��ǰ׺
        t=t+1;
    end
end
dataset.name=namestr;

%% ��ȡ������Ӧ����ֵ
valstr=cell(len_sum+length(len_sig),1);
t=1;
for i=1:len_labset
    t=t+1;%����ʱ������
    %vstr=evalin('base',labset{i}(1:length(labset{i})-6));
    vstr=getfield(loadfile,labset{i}(1:length(labset{i})-6));
    for j=1:len_sig(i)
        valstr{t}=vstr(:,j+sigt(i));
        t=t+1;
    end
end

%% ��ȡʱ�������Ӳ�ͬ������ʱ������
for i=1:len_labset
    %temp=evalin('base',labset{i}(1:length(labset{i})-6));
    temp=getfield(loadfile,labset{i}(1:length(labset{i})-6));
    cntset_tdata{i}=temp(:,1);%�������ʱ����������ڵ�һ������
end
t=1;
for i=1:(length(valstr)-1)
    %���ղ�ͬ�����������Ե�ʱ���������
    if isempty(valstr{i})
        valstr{i}=cntset_tdata{t};
        t=t+1;
    end
end
dataset.value=valstr;

%% ��װ���ݵ�dat�ļ����ڻ�ͼ����
wr2dir=strcat(PathName,FileName(1:length(FileName)-4),'.dat');
wr2datfiles(wr2dir,dataset,len_sig);%��ֹ�������ļ��޷���ȷ�ͷţ����ú�����ʽ


end


function wr2datfiles(dir,data,tmlabel)
namestr=data.name;
valstr=data.value;
len_namestr=length(namestr);
len_val=cell(len_namestr,1);
for i=1:len_namestr
    len_val{i}=num2str(length(valstr{i}));
end
label=cell(length(tmlabel),1);
for i=1:length(tmlabel)
    label{i}=num2str(tmlabel(i));
end
numstr=num2str(length(namestr));
len_label=length(label);
fid=fopen(dir,'w');
%�������־��ͷ�ļ���һ�У�������������Ϊʱ�����ǩ����,��־λflag��AnakinQinForAPMdata
fprintf(fid,repmat('%s_',1,len_label),label{:});
fprintf(fid,'%s','AnakinQin4APMdata+');
fprintf(fid,strcat(repmat('%s_',1,len_namestr),'\n'),len_val{:});
fprintf(fid,'%s\n',numstr);
fprintf(fid,strcat(repmat('%s ',1,len_namestr),'\n'),namestr{:});
for i=1:len_namestr
    fprintf(fid,strcat(repmat('%f ',1,length(valstr{i})),'\n'),valstr{i});
end

fclose(fid);



end


function y=isrgtlabel(x,nameset)
y=false;
for i=1:length(nameset)
    if strcmp(x,nameset{i})
        y=true;
        return;
    end
end


end


function opt=isstrsame(x,y,i)
% return ture if str x is totally the same as y
% param i==1 indicate the compare method with searching for the upper and
% lower case. while i==0 means to ignore it.
if (~ischar(x) || ~ischar(y))
    opt=0;
    return;
end
lenx=length(x);
leny=length(y);
if (lenx~=leny)
    opt=0;
    return;
end
cnt=0;
for i=1:lenx
    if (x(i)~=y(i))
        opt=0;
        return;
    end
    cnt=cnt+1;
end
if cnt==lenx
    opt=1;
    return;
end
end