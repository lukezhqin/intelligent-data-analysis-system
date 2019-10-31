function EnableMenu(i_windows,n_windows)
% configuration for the menu enable


h_MainPlotFig = findobj('Tag','Main Plot Figure');
h1_findmenu=findobj('label','First Figure       Home');
h2_findmenu=findobj('label','Previous Figure    ←');
h3_findmenu=findobj('label','Next Figure        →');
h4_findmenu=findobj('label','Last Figure        End');

handles.customtoolbar=findobj(h_MainPlotFig,'Tag','ViewToolBar');
handles.NewIDAS=findobj(handles.customtoolbar,'TooltipString','New Figure');
handles.Layout=findobj(handles.customtoolbar,'TooltipString','Layout');
handles.Refresh=findobj(handles.customtoolbar,'TooltipString','Refresh');
handles.Axis=findobj(handles.customtoolbar,'TooltipString','Axis');
handles.Copy=findobj(handles.customtoolbar,'TooltipString','Copy');
handles.First=findobj(handles.customtoolbar,'TooltipString','First');
handles.Previous=findobj(handles.customtoolbar,'TooltipString','Previous');
handles.Next=findobj(handles.customtoolbar,'TooltipString','Next');
handles.Last=findobj(handles.customtoolbar,'TooltipString','Last');


if n_windows==1
    set(h1_findmenu,'enable','off')
    set(h2_findmenu,'enable','off')
    set(h3_findmenu,'enable','off')
    set(h4_findmenu,'enable','off')
    set(handles.First,'Enable','off')
    set(handles.Previous,'Enable','off')
    set(handles.Next,'Enable','off')
    set(handles.Last,'Enable','off')
else
    switch i_windows
        case 1
            set(h1_findmenu,'enable','off')
            set(h2_findmenu,'enable','off')
            set(h3_findmenu,'enable','on')
            set(h4_findmenu,'enable','on')
            set(handles.First,'Enable','off')
            set(handles.Previous,'Enable','off')
            set(handles.Next,'Enable','on')
            set(handles.Last,'Enable','on')
        case n_windows
            set(h1_findmenu,'enable','on')
            set(h2_findmenu,'enable','on')
            set(h3_findmenu,'enable','off')
            set(h4_findmenu,'enable','off')
            set(handles.First,'Enable','on')
            set(handles.Previous,'Enable','on')
            set(handles.Next,'Enable','off')
            set(handles.Last,'Enable','off')
        otherwise
            set(h1_findmenu,'enable','on')
            set(h2_findmenu,'enable','on')
            set(h3_findmenu,'enable','on')
            set(h4_findmenu,'enable','on')
            set(handles.First,'Enable','on')
            set(handles.Previous,'Enable','on')
            set(handles.Next,'Enable','on')
            set(handles.Last,'Enable','on')
    end
end

verstr='IDAS_V1.8';
%今后完成一次性读取并保存所有“FMT,”的数据格式并按照cfg文件去选择绘图变量并且能够将所有数据按照结构体的数据结构来存放，就可以将版本号升级到2.0
figName=[verstr,' Powered by Luke.Qin','           Page:',num2str(i_windows),'/',num2str(n_windows)];
set(h_MainPlotFig,'name',figName);