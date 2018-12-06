function UpdateMatList(TableHandle, Ci, CloseImmediately)
%Update a material list in a table with a new materials database
%TableHandle is a handle to the table of inerest
%Ci is the column number of that table that has materials listed

    F=get(TableHandle,'userdata');
    
    if isempty(F) || not(isvalid(F))
        F=MaterialDatabase;  %Instantiate the materials database window
        set(TableHandle,'userdata',F);
        drawnow  %Seems to be needed to ensure that GUI can render properly
    end
    
    if exist('CloseImmediately','var')
        set(F,'visible','off')
    else
        set(F,'windowstyle','modal')
        set(F,'visible','on')
        uiwait(F)
        set(F,'windowstyle','normal')
    end
    
    M=getappdata(F,'Materials');
    NewMatList=reshape(M.Material,[],length(M.Material));

    ColFormat=get(TableHandle,'columnformat');
    OldMatList=ColFormat{Ci};
    Data=get(TableHandle,'data');
    if not(isempty(Data))
        for I=1:length(Data(:,1))
            MatIndex=find(strcmpi(Data(I,Ci),NewMatList));
            if isempty(MatIndex)
                ThisMat='';
            else
                ThisMat=NewMatList{MatIndex};
            end
            Data{I,Ci}=ThisMat;
        end
    end
    ColFormat{Ci}=NewMatList;
    set(TableHandle,'columnformat',ColFormat);
    set(TableHandle,'data',Data);
end