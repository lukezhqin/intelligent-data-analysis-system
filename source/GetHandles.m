function handles=GetHandles


handles.IDAS = findobj('Name','IDAS');

h_children=get(handles.IDAS,'Children');
handles.varlist             =   findobj(h_children,'Tag','varlist');
handles.varorder            =   findobj(h_children,'Tag','varorder');
handles.extend              =   findobj(h_children,'Tag','extend');
handles.uipanel             =   findobj(h_children,'Type','uipanel');
handles.Export              =   findobj(h_children,'Tag','export');
handles.Plot                =   findobj(h_children,'String','Plot');
handles.Exit                =   findobj(h_children,'String','Exit');
handles.text_axis           =   findobj(h_children,'Tag','text_axis');
handles.text_TotalVarNo     =   findobj(h_children,'Tag','text_TotalVarNo');
handles.text_SelectedVarNo   =  findobj(h_children,'Tag','text_SelectedVarNo');
handles.PerformanceStatistic =  findobj(h_children,'Tag','PerformanceStatistic');
% the handles in the uipanel
handles.filelist            =   findobj(h_children,'Tag','filelist');
% handles.editbox_headerfile  =   findobj(h_children,'Tag','editbox_headerfile');
handles.filelist_comp            =   findobj(h_children,'Tag','filelist_comp');% add for plot compare
handles.extend_comp             =    findobj(h_children,'Tag','extend_comp');% add for plot compare
handles.newDocument             =    findobj(h_children,'Tag','newDocument');% add for plot compare
handles.mrklist             =  findobj(h_children,'Tag','mrklist');

