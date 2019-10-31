function [nvar,varlist]=readheader(File)

fid=fopen(File);
str=fscanf(fid,'%s',1);
% judge the str style
% APM飞控数据，时间标记多速率组
tokens0=textscan(str,'%s','Delimiter','+');
tokens0=tokens0{1};
if length(tokens0{1})>=17
    flag=strcmp(tokens0{1}(length(tokens0{1})-17+1:end),'LukeQin4APMdata');
else
    flag=0;
end
if length(tokens0)~=1 && flag
    %flag:LukeQin4APMdata再次确认token第一个元胞数组末尾17个字符长度是否正确
    tokens1=textscan(tokens0{1},'%s','Delimiter','_');
    tokens1=tokens1{1};
    tokens2=textscan(tokens0{2},'%s','Delimiter','_');
    tokens2=tokens2{1};
    len_labset=length(tokens1)-1;%去掉末尾的flag标志位
    len_valset=length(tokens2);
    labset=zeros(len_labset,1);
    valset=zeros(len_valset,1);
    for i=1:len_labset
        labset(i)=str2double(tokens1{i});
    end
    for i=1:len_valset
        valset(i)=str2double(tokens2{i});
    end
    skipline=fgetl(fid);%行末换行符
    InputText=fscanf(fid,'%f',1);
    nvar=InputText-len_labset;%去掉每个速率组时间量
    inplist=cell(1,InputText);
    for i=1:InputText
        inplist{i}=fscanf(fid,'%s',1);
    end
    varlist=cell(1,nvar);
    t=1;
    for i=1:InputText
        if ~strcmp(inplist{i}(1:2),'t_')%去掉时间变量标记
            varlist{t}=inplist{i};
            t=t+1;
        end
    end
    return;
end
%常规数据读取
if strcmpi(str,'fcs_time') % adas 原始数据格式，绝对时间hh:mm:ss
    skipline=fscanf(fid,'%s',1);         % skip 'flight_time'
    skipline=fgetl(fid);         % skip the var 'Time'
    varlist=textscan(skipline,'%s');
    varlist=varlist{1,1};
    nvar=length(varlist);
else
    skipline=fgetl(fid);
    InputText=fscanf(fid,'%f',1);
    nvar=InputText;
    nvar=nvar-1;
    skipline=fscanf(fid,'%s',1);         % skip the var 'Time'
    for ivar=1:nvar
        varlist{ivar}=fscanf(fid,'%s',1);
    end
end
fclose(fid);
%strtrim: Remove leading and trailing whitespace from string
%whitespace: Use the whitespace  as delimiter to preserve leading and trailing spaces in a string