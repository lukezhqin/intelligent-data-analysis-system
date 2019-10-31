function idasdata=readdata(File,varlist)
% updata：
%     1. 更改FormatString，优化数据读取，y
%     2. 增加对自带头文件类型的支持，要求数据文件第一行为变量个数（包含time），第二行为变量列表，第三行开始为数据，
%     3. 使用textscan提高读取效率3倍，并同时支持读取利用饶晓软件处理前、后的adas数据，


% 显示进度条
SizeofFile=0;
newfileinfo=cell(length(File),1);
for i=1:length(File)
    newfileinfo{i} = dir(File{i});
    SizeofFile=SizeofFile+newfileinfo{i}.bytes;
end
TimeToRead=SizeofFile/139699962*4;% 读取137MB数据大概要4s
strDisp='';
strName=sprintf('数据读取中，约需时%ds',round(TimeToRead));
hwaitbar = waitbar(0,strDisp,'Name',strName);
set(get(get(hwaitbar,'Children'),'Title'),'Interpreter','none'); % waitbar实际上是一个figure，strDisp所在的'message'是其中axes的标题
% 读取数据
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
        idasdata{iFile}.varlist=varlist;
        fid=fopen(File{iFile});
        if fid<0
            error([File{iFile},' isn''t exist!']);
        end
        str=fscanf(fid,'%s',1);
        frewind(fid); % textscan效率为dlmread的1.5倍，也可以只读取数据块矩阵中指定区域的数据，可用来跳过 绝对时间hh:mm:ss
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
            skipline=fgetl(fid);%行末换行符
            idasdata{iFile}.Time=cell(len_labset,1);
            idasdata{iFile}.Data=cell(nvar,1);
            tnulab=zeros(len_labset,1);%labset;
            tnulab(1)=1;
            for i=2:len_labset
                tnulab(i)=tnulab(i-1)+labset(i-1)+1;
            end
            idasdata{iFile}.label=tnulab;
            tnulab_len=zeros(len_labset,1);
            vallab_len=zeros(nvar,1);
            k=1;
            t=1;
            p=1;
            for i=1:InputText
                if i==tnulab(p)
                    tnulab_len(k)=valset(i);
                    k=k+1;
                    p=p+1;
                    if p>len_labset
                        p=len_labset;
                    end
                else
                    vallab_len(t)=valset(i);
                    t=t+1;
                end
            end
            for i=1:len_labset
                idasdata{iFile}.Time{i}=zeros(tnulab_len(i),1);
            end
            for i=1:nvar
                idasdata{iFile}.Data{i}=zeros(vallab_len(i),1);
            end
            data = textscan(fid,'%f32');
            data = data{1};
            k=1;
            t=1;
            qq=1;%从读取的数据data中取值
            %prealloc
            for i=1:InputText
                if strcmp(inplist{i}(1:2),'t_')%时间变量标记
                    idasdata{iFile}.Time{k}=zeros(valset(i),1);
                    k=k+1;
                else
                    idasdata{iFile}.Data{t}=zeros(valset(i),1);
                    t=t+1;
                end
            end
            k=1;
            t=1;
            for i=1:InputText
                if strcmp(inplist{i}(1:2),'t_')%时间变量标记
                    fromto=calc_intvel(valset,i);
                    %                     for j=1:valset(i)
                    %                         idasdata{iFile}.Time{k}(j)=fscanf(fid,'%f',1);
                    %                         idasdata{iFile}.Time{k}=data(qq);
                    %                         qq=qq+1;
                    %                    end
                    idasdata{iFile}.Time{k}=data(fromto(1):fromto(2));
                    k=k+1;
                else
                    fromto=calc_intvel(valset,i);
                    %                     for p=1:valset(i)
                    %                         % idasdata{iFile}.Data{t}(p)=fscanf(fid,'%f',1);
                    %                         idasdata{iFile}.Data{t}(p)=data(qq);
                    %                         qq=qq+1;
                    %                     end
                    idasdata{iFile}.Data{t}=data(fromto(1):fromto(2));
                    t=t+1;
                end
            end
            
        else
            %常规数据读取
            if strcmpi(str,'fcs_time') % adas 原始数据格式，绝对时间hh:mm:ss
                %         data=dlmread(File{iFile},'',1,2); % 跳过1行2列
                data = textscan(fid,'%f32','Delimiter',' \b\t:','MultipleDelimsAsOne',1,'headerlines',1);% 指定为'%f32'格式时，后面跟headercolumns属性不起作用
                columnSkip=6;
                data=reshape(data{1},nvar+columnSkip,[]);
                [m,n]=size(data);
                idasdata{iFile}.Time=0.015*[0:n-1];
                idasdata{iFile}.Data=data(columnSkip+1:end,:);
            elseif strcmpi(str,'this')
                frewind(fid);
                fgetl(fid);
                nvars=fscanf(fid,'%d',1);
                [~]=textscan(fid,'%s',nvars);
                data = textscan(fid,'%f32');% 指定为'%f32'格式时，后面跟headercolumns属性不起作用
                data=reshape(data{1},nvars,[]);
                [m,n]=size(data);
                idasdata{iFile}.Time=0.015*[0:n-1];
                idasdata{iFile}.Data=data(2:end,:);
            else                       % adas 处理后数据格式，相对时间ss
                data = textscan(fid, '%f32','HeaderLines',4); % 跳过4行0列
                data=reshape(data{1},nvar+1,[]);
                idasdata{iFile}.Time=data(1,:);
                idasdata{iFile}.Data=data(2:end,:);
            end
        end
        fclose(fid);
        waitbar(iFile/nfile,hwaitbar,strDisp)
    end
catch
    fclose all;
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

