function [nvar,varlist]=readheader_mat_log_bin(File)
% Copyright @XXX 2017-2019 All Rights Reserved.#
% Author   : Anakin.Qin  2017.12.26 11:16:24   #
% Website  : https://anakinqin.github.io       #
% E-mail   : zonghang.qin@foxmail.com          #
% Intelligent Data Analysis System(IDAS)
rootpath=pwd;
%% ��������,����ȡ�����ļ�
if ~ischar(File)
    fprintf('ѡ����ļ�����ȷ\n');
    return;%��ʱδ��Ӷ��ļ�ѡ��ֻ�ܵ����ļ�����
end
%% ��ȡlog��ʽ�ļ�
%�����׺
% [pathstr, name, ext] = fileparts(File);
[~, ~, ext] = fileparts(File);
if (strcmpi(ext,'.bin'))
    %% ��ȡ����ͷbin��ʽ
    fid = fopen(File);
    if (fid==-1)
        errordlg('�ļ�ϵͳ���ش���');
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
    %��ʱ��δ�����bin�ļ���ȡ:a=fread(fid)ֱ�Ӷ�ȡ�������ļ���������Ҫ֪������Э�飬�ȴ�2.0�汾���з���bin�ļ�ֱ�Ӷ�ȡ����--->89һ������
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
    for i=1:8
        fgetl(fid);
    end
    %ʱ�䵥λѡ��
    fgetl(fid);
    tmunit=fscanf(fid,'%s',1);
    fgetl(fid);
    fgetl(fid);
    fgetl(fid);
    numscan=fscanf(fid,'%f',1);
    fuck=cell(1,numscan);
    scanset=cell(2,1);
    %��ӡ�//�����ƶ�ȡĩβ�Ĺ��ܣ��������������ںϡ����Ȱ�����������ȡ������һ������ֹͣ����//������ֹͣ��
    for i=1:numscan
        temp=fscanf(fid,'%s',1);
        %��ӡ�//������ǿ����ֹ��ȡ�Ĺ��ܣ�����Ҫ��ָ����ȡ��������֮�ڲ���������
        if i==numscan || strcmp(temp,'//')
            break;
        else
            fuck{i}=temp;
        end
    end
    fclose(fid);
    %ȥ��'_label'��ǩ�ֽ�
    t=1;
    for i=1:numscan
        if ~isempty(fuck{i})
            scanset{t}=fuck{i}(1:(length(fuck{i})-6));
            t=t+1;
        end
    end
    fuck=[];
    scanset_len=length(scanset);
    
    %% ��ȡ����ͷlog��ʽ
    fid = fopen(File);
    if (fid==-1)
        errordlg('Corruption in file system��');
        return;
    end
    textscandata=cell(2,1);
    i=1;
    %     while(~feof(fid))
    while(i<3000)
        textscandata{i}=fgetl(fid);
        tokens=textscan(textscandata{i},'%s','Delimiter',',');
        tokens=tokens{1};
        i=i+1;
        %���á�MSG����Ϊͷ�ļ���ǩ��ȡ�Ľ���λ��(MSG, 131114894, TIM_GNC: F1_V3.2.2)
        if (strcmp('MSG',tokens{1}))
            break;
        end
    end
    fclose(fid);
    [valid_scanset,len_sig,ptr_sig]=findchecklabel(textscandata,scanset);
    minussss=scanset_len-valid_scanset;
    delta=10000;
    cnt=0;
    isfinished=0;
    while(~isfinished && minussss~=0 && cnt<50)%û�������������¶�ȡ����,����ظ��ۼ�50��
        cnt=cnt+1;
        textscandata=cell(2,1);
        i=1;
        fid = fopen(File);
        while((~feof(fid))&&(i<(cnt*delta)))
            textscandata{i}=fgetl(fid);
            i=i+1;
        end
        if(feof(fid))
            isfinished=1;
        end
        fclose(fid);
        [valid_scanset,len_sig,ptr_sig]=findchecklabel(textscandata,scanset);
        minussss=scanset_len-valid_scanset;
    end
    %ȥ�������Ҳ��������ݱ�ǩ
    if (minussss~=0)
        scanset_final=cell(valid_scanset,1);
        temp1=zeros(valid_scanset,1);
        temp2=zeros(valid_scanset,1);
        k=1;
        for i=1:scanset_len
            if (len_sig(i)~=0)
                scanset_final{k}=scanset{i};
                temp1(k)=len_sig(i);
                temp2(k)=ptr_sig(i);
                k=k+1;
            else
                %��ʾ���Ǽ�����ǩ�����ڣ������ڵ����ݱ�ǩ���������ݶԱȷ�����
                str_war=strcat('Data label: ',scanset{i},'_label is NOT exist!');
                warndlg(str_war,'���ݱ�ǩȱʧ');
            end
        end
        len_sig=[];
        ptr_sig=[];
        scanset=[];
        scanset=scanset_final;
        len_sig=temp1;
        ptr_sig=temp2;
    end
    %������ָ���ж�ȡ�����ļ��е�ƥ���ǩ����
    nvar=0;
    varlist=cell(2,1);
    temp=1;
    for i=1:valid_scanset
        nownum=len_sig(i);
        nvar=nvar+nownum;
        tokens=textscan(textscandata{ptr_sig(i)},'%s','Delimiter',',');
        tokens=tokens{1};
        start_cnt=length(tokens)-nownum+1;
        for j=1:nownum
            varlist{temp}=strcat(scanset{i},'_',tokens{start_cnt});
            start_cnt=start_cnt+1;
            temp=temp+1;
        end
    end
    %sort the data label
    varlist = mysort_dash(varlist);
    clearvars -except nvar varlist
    return;
end
%% ��ȡmat��ʽ�ļ�
whosdata = whos('-file',File);
if strcmp(whosdata(1).name,'@')%ȥ�������־��
    whosdata=whosdata(2:end);
end
getallname=cell(length(whosdata),1);
for i=1:length(whosdata)
    getallname{i}=whosdata(i).name;
end
whosdata=[];%�ͷ��ڴ�
loadfile=load(File,getallname{:});
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
for i=1:8
    fgetl(fid);
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
%��ӡ�//�����ƶ�ȡĩβ�Ĺ��ܣ��������������ںϡ����Ȱ�����������ȡ������һ������ֹͣ����//������ֹͣ��
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
% len_labset = numscan-minussss;
len_labset = validscan-minussss;%��validscan���ԭ����numscan
labset=cell(1,len_labset);
for i=1:len_labset
    labset{i}=scanset{i};
end
scanset = [];%release load
%% ��ȡ����Ҫת���ı�������
% labset={'ATT_label','BAR2_label','BARO_label','CTRL_label','CTUN_label','GPS_label','IMU_label','IMU2_label','IMU3_label','MAG_label','MAG2_label','MAG3_label','NKF1_label','NKF6_label',...
%     'NTUN_label','POS_label','RCIN_label','RCOU_label','TERR_label'};
len_sig=zeros(len_labset,1);
nstr=cell(len_labset,1);
for i=1:len_labset
    %     temp=(eval(labset{i}));
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
        end
    end
    tokens=textscan(nstr{i},'%s','Delimiter',',');
    nstr{i}=tokens{1};
    len_sig(i)=num;
end
loadfile = [];%�ͷ��ڴ�
nvar=0;
for i=1:length(len_sig)
    nvar=nvar+len_sig(i);
end
varlist=cell(nvar,1);
t=1;
for i=1:len_labset
    %t=t+1;%����ʱ���ǩ
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
clearvars -except nvar varlist
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

function [valid_scanset,len_sig,ptr_sig]=findchecklabel(textscandata,scanset)
textscanlen=length(textscandata);
scanset_len=length(scanset);
len_sig=zeros(scanset_len,1);
ptr_sig=zeros(scanset_len,1);
%FMT, 128, 89, FMT, BBnNZ, Type,Length,Name,Format,Columns
%fuck the first line
valid_scanset=0;
i=1;
while (i<=textscanlen)
    tokens=textscan(textscandata{i},'%s','Delimiter',',');
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

%strtrim: Remove leading and trailing whitespace from string
%whitespace: Use the whitespace  as delimiter to preserve leading and trailing spaces in a string