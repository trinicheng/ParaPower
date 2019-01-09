function Visualize (PlotTitle, MI, varargin)
%Visualize creates a graphic visualization of the model and takes two forms
%(one for results and one for initial conditions)
%
%visualize (PlotTitle, MI, 'propery_1','value_1', 'propery_n','value_n')
%
%   MI is the model information structure provided by FormModel
%
%   2D - X+, X-, Y+, Y-, Z+, Z- - plot only those faces. Can be called
%      multiplie time to include multiple faces.
%   ScaleTitle  - title of the colorbar, value is a char array
%   State - a matrix the same dimenstions as modelmat with the state to plot, value is 3 dim array
%   PlotParms.RemoveMaterial=[] - Which materials to remove from the plot, value is array of mat numbers
%   EdgeOnlyMaterial=[] - Show only the edges of this material, value is array of mat numbers
%   Transparency=0.5 - FaceAlpha value, 0-clear, 1-opaque, value is a scalar between 0 & 1
%   ShowQ, time - Display Q on each face, no value, this is a flag and
%   value.  If no value, then 0 is assumed.  Note that positive Q indicates
%   a heat source.
%   EdgeColor=[0 0 0] - Color of the edges ('none' or [R,G,B] value), value is color as 3x1 RGB array
%   ModelGeometry - plot model geometry, no value, this is a flag to just plot model geometry
%   TransMaterial=[] - List of materials to make transparent, value is array of mat numbers that should be transparent
%   MinCoord=[0 0 0] - Set of model origin (minimum of X, Y & Z), value is a 3 element vecotr that identifies minimum (X,Y,Z) of model
%   NoAxis - Do not plot the axes (they help maintain aspect ration in the plot), no value, this is a flag to remove the axes
%   RemoveMaterial=[0] - Materials to remove entirely from display
%   ShowExtent=false - Show extent of the model by a box
%   HideBC - Do not show H/Temp boundary conditions on plot
%
%To Do Features:
%  X cross section
%  Y cross Section
%  Z cross section
%  Vectorize


    ThisAxis=gca;
    AxisParent=get(ThisAxis,'parent');
    Kids=get(AxisParent,'children');
    for i=1:length(Kids)
        if strcmpi(get(Kids(i),'userdata'),'REMOVE');
            delete(Kids(i))
        end
    end
    cla;drawnow
    DrawStatus=text(.5,.5,'Drawing...','fontsize',40,'userdata','REMOVE','horizontal','center','vertical','middle','unit','normal'); drawnow

    DeltaCoord=  {MI.X MI.Y MI.Z};
    ModelMatrix=MI.Model;
	
	SzModel=size(ModelMatrix);
	if (length(MI.X) ~= SzModel(1)) || (length(MI.Y) ~=SzModel(2)) || (length(MI.Z) ~= SzModel(3))
		fprintf(' %10s %9s %9s %9s \n %10s %9i %9i %9i \n %10s %9i %9i %9i\n', ...
		           '','Rows(X)','Columns(Y)','Layers(Z)', ...
				   'Model',SzModel(1),SzModel(2),SzModel(3), ...
				   'Vectors',length(MI.X),length(MI.Y),length(MI.Z))
		error('There is a size mismatch between the Model and the X, Y or Z vectors');
	end


    PlotGeom=true; %If no other parameters are called, then plot the model geom
    h=MI.h;
    Ta=MI.Ta;
    matlist=MI.MatLib.Material;

    
    %Note that any PlotParms field ending in 'Matl' will have negative
    %materials swapped for their positive counterparts
    PlotParms.RemoveMatl=[0];
    PlotParms.EdgeOnlyMatl=[];
    PlotParms.TransMatl=[];
    PlotParms.Transparency=0.5;
    PlotParms.EdgeColor=[];
    PlotParms.PlotAxes=true;
    PlotParms.TwoD={};
    PlotParms.ShowExtent=false;
    PlotParms.HideBC=false;
    PlotParms.MinCoord=MI.OriginPoint;
    ColorTitle='';
    PlotState=[];
    Q=[];
    PlotParms.ShowButtons=true;
    Qt=0; %Time at which Q will be evaluated

    strleft=@(S,n) S(1:min(n,length(S)));

    QList=containers.Map;
    
    if (not(isempty(varargin))) && iscell(varargin{1})
        PropValPairs=varargin{1};
    else
        PropValPairs=varargin;
    end
    while ~isempty(PropValPairs) 
        [Prop, PropValPairs]=Pop(PropValPairs);
        if ~ischar(Prop)
            error('Property name must be a string.');
        end
        Pl=length(Prop);
        %disp(Prop)
        switch lower(Prop)
            case strleft('scaletitle',Pl)
                [Value, PropValPairs]=Pop(PropValPairs); 
                ColorTitle=Value;
            case strleft('2d',Pl)
                [Value, PropValPairs]=Pop(PropValPairs); 
                PlotParms.TwoD=[PlotParms.TwoD upper(Value)];
            case strleft('state',Pl)
                [Value, PropValPairs]=Pop(PropValPairs); 
                PlotGeom=false;
                PlotState=Value;
            case strleft('removematerial',Pl)
                [Value, PropValPairs]=Pop(PropValPairs); 
                PlotParms.RemoveMatl=Value;
            case strleft('edgeonlymaterial',Pl)
                [Value, PropValPairs]=Pop(PropValPairs); 
                PlotParms.EdgeOnlyMatl=Value;
            case strleft('showbuttons',Pl)
                [Value, PropValPairs]=Pop(PropValPairs); 
                PlotParms.ShowButtons=Value;
            case strleft('transmaterial',Pl)
                [Value, PropValPairs]=Pop(PropValPairs); 
                PlotParms.TransMatl=Value;
            case strleft('transparency',Pl)
                [Value, PropValPairs]=Pop(PropValPairs); 
                PlotParms.Transparency=Value;
            case strleft('showq',Pl)
                [Value, NewPropValPairs]=Pop(PropValPairs);
                if isnumeric(Value)
                    PropValPairs=NewPropValPairs;
                    Qt=Value;
                end
                Q=MI.Q;
            case strleft('showextent',Pl)
                PlotParms.ShowExtent=true;
            case strleft('noaxes',Pl)
                PlotParms.PlotAxes=false;
            case strleft('edgecolor',Pl)
                [Value, PropValPairs]=Pop(PropValPairs); 
                PlotParms.EdgeColor=Value;
            case strleft('mincoord',Pl)
                [Value, PropValPairs]=Pop(PropValPairs); 
                PlotParms.MinCoord=Value;
            case strleft('hidebc',Pl)
                PlotParms.HideBC=true;
            case strleft('modelgeometry',Pl)
                h=MI.h;
                Ta=MI.Ta;
                matlist=MI.MatLib.Material;
                PlotGeom=true;
            otherwise
                fprintf('Property "%s" is unknown.\n',Prop)
        end

    end
    
    Direx=FormModel('GetDirex');


    %Check for negative mat numbers and if present map into new matnumber
    %iwth high number and inform of deprecation
    if min(ModelMatrix(:))<=0
        if min(ModelMatrix(:))<0
            disp('Negative material numbers are present that represent voids.')
            disp('While currently permitted, this functionality is deprecated')
            disp('and will be removed in a future release.  Voids are now handled')
            disp('using a material of type ''IBC.''')
        end
        VoidMaterials=unique(ModelMatrix(:));
        MaxMaterial=max(VoidMaterials(:));
        VoidMaterials=VoidMaterials(VoidMaterials<=0); %Extract all materials less than zero.
        for Vmat=reshape(VoidMaterials,1,[]);
            MaxMaterial=MaxMaterial+1;
            ModelMatrix(ModelMatrix==Vmat)=MaxMaterial;
            if Vmat==0
                matlist{MaxMaterial}='Empty';
            else
                matlist{MaxMaterial}=sprintf('Void %1.0f',Vmat);
            end
            if Vmat < 0
                fprintf('  Mapping void material %1.0f to %1.0f.\n',Vmat,MaxMaterial);
            end
            Fields=fieldnames(PlotParms);
            for Fi=1:length(Fields)
                ThisField=Fields{Fi};
                L=findstr(lower(ThisField),lower('Matl'));
                if not(isempty(L)) && ((length(ThisField)-L)==3)
                    Value=getfield(PlotParms,ThisField);
                    Value(Value==Vmat)=MaxMaterial;
                    PlotParms=setfield(PlotParms,ThisField,Value);
                end
            end
        end
    end

    %Visualization of defined model

    X=[PlotParms.MinCoord(1) PlotParms.MinCoord(1) + cumsum(DeltaCoord{1})];
    Y=[PlotParms.MinCoord(2) PlotParms.MinCoord(2) + cumsum(DeltaCoord{2})];
    Z=[PlotParms.MinCoord(3) PlotParms.MinCoord(3) + cumsum(DeltaCoord{3})];

    if isempty(PlotState)
        PlotState=ModelMatrix;
    end
    MatListNumbers=unique(ModelMatrix(:));
    VList=cell(length(MatListNumbers),1);     %OPTIM
    FList=cell(length(MatListNumbers),1);   %OPTIM
    CList=cell(length(MatListNumbers),1);
    CVList=cell(length(MatListNumbers),1);
    QFList=cell(length(MatListNumbers),1);
    FAList=cell(length(MatListNumbers),1);
    for Ci=1:length(PlotParms.RemoveMatl)
        MatListNumbers=MatListNumbers(MatListNumbers~=PlotParms.RemoveMatl(Ci));
    end
    
    for Imat=1:length(MatListNumbers)
%        PlotParms.MatPatchList{Imat}=zeros(1,2*length(find(ModelMatrix(:)==MatList(Imat))));
         MatPatchList{Imat}=[];
    end
        
    if ~all(size(PlotState)==size(ModelMatrix))
        error('The dimensions of the plotstate provided do not match the dimensions of the model.')
    end
    ButtonColors=colormap(parula(length(MatListNumbers)));
        
    if PlotGeom
        ColorList=unique(PlotState(:));  
        for Ci=1:length(PlotParms.RemoveMatl)
            ColorList=ColorList(ColorList~=PlotParms.RemoveMatl(Ci));
        end
        CM=colormap(parula(length(ColorList)));
        ValMin=1;
        ValRange=length(ColorList);
    else
        CM=colormap(parula(64));
        ValMin=min(PlotState(:));
        ValRange=max(PlotState(:))-ValMin;
        if ValRange==0
            ValRange=1;
        end
    end

    hold on
    drawnow nocallbacks limitrate
    for Xi=1:length(X)-1
        for Yi=1:length(Y)-1
            for Zi=1:length(Z)-1
                if isempty(find(ModelMatrix(Xi,Yi,Zi) == PlotParms.RemoveMatl, 1))
                    Zoffset=0;
                    Xoffset=0;
                    Yoffset=0;
                    if (Z(Zi)==Z(Zi+1)) || (Y(Yi)==Y(Yi+1)) || (X(Xi)==X(Xi+1))
                        FaceAlpha=1;
                        if Z(Zi)==Z(Zi+1)
                            Zoffset=min(DeltaCoord{3}(DeltaCoord{3}>0))*.01;
                        end
                        if X(Xi)==X(Xi+1)
                            Xoffset=min(DeltaCoord{1}(DeltaCoord{1}>0))*.01;
                        end
                        if Y(Yi)==Y(Yi+1)
                            Yoffset=min(DeltaCoord{2}(DeltaCoord{2}>0))*.01;
                        end
                    else
                        FaceAlpha=PlotParms.Transparency;
                    end
                    P(1,:)=[X(Xi)   Y(Yi)   Z(Zi)  ] + [  Xoffset  Yoffset  Zoffset] ;
                    P(2,:)=[X(Xi)   Y(Yi+1) Z(Zi)  ] + [  Xoffset -Yoffset  Zoffset] ; 
                    P(3,:)=[X(Xi+1) Y(Yi+1) Z(Zi)  ] + [ -Xoffset -Yoffset  Zoffset] ;
                    P(4,:)=[X(Xi+1) Y(Yi)   Z(Zi)  ] + [ -Xoffset  Yoffset  Zoffset] ;
                    P(5,:)=[X(Xi)   Y(Yi)   Z(Zi+1)] + [  Xoffset  Yoffset -Zoffset] ;
                    P(6,:)=[X(Xi)   Y(Yi+1) Z(Zi+1)] + [  Xoffset -Yoffset -Zoffset] ;
                    P(7,:)=[X(Xi+1) Y(Yi+1) Z(Zi+1)] + [ -Xoffset -Yoffset -Zoffset] ;
                    P(8,:)=[X(Xi+1) Y(Yi)   Z(Zi+1)] + [ -Xoffset  Yoffset -Zoffset] ;
                    Face(1,:)=[1 2 3 4]; %Z-
                    Face(2,:)=[1 5 6 2]; %X-
                    Face(3,:)=[1 4 8 5]; %Y-
                    Face(4,:)=[7 6 5 8]; %Z+
                    Face(5,:)=[7 8 4 3]; %X+
                    Face(6,:)=[7 3 2 6]; %Y+
                    %fprintf('Xi=%i, Yi=%i, Zi=%i  (%g, %g, %g) (%g, %g, %g)\n',Xi, Yi,Zi, X1, Y1, Z1, X2, Y2, Z2)
                    if ~isempty(find(ModelMatrix(Xi,Yi,Zi) == PlotParms.TransMatl, 1))
                        FaceAlpha=PlotParms.Transparency;
                    end
                    if PlotGeom
                        ThisColor=find(ColorList==PlotState(Xi,Yi,Zi));
                    else
                        ThisColor=floor((PlotState(Xi,Yi,Zi)-ValMin)/ValRange*(length(CM(:,1))-1) + 1);
                        %fprintf('%i ',ThisColor)
                    end
                    ThisMat=find(MatListNumbers==ModelMatrix(Xi,Yi,Zi));
                    ThisVertC = ones(length(P),1) * CM(ThisColor,:);
                    if ~isnan(ThisColor)
                        if isempty(PlotParms.TwoD)
                            VList{ThisMat}=[VList{ThisMat}; P];              %OPTIM              
                            PtStart=length(VList{ThisMat}(:,1))-length(P(:,1)); %OPTIM
                            ThisFace  = Face+PtStart;
                            ThisFaceC = ones(length(Face(:,1)),1) * CM(ThisColor,:);
                        else
                            F=[];
                            if any(strcmp(PlotParms.TwoD,'X+'))
                                ThisFace  =  Face(5,:)+PtStart;  %OPTIM
                                ThisFaceC =  CM(ThisColor,:);
                            end
                            if any(strcmp(PlotParms.TwoD,'X-'))
                                ThisFace  =  Face(2,:)+PtStart;  %OPTIM
                                ThisFaceC = CM(ThisColor,:);
                            end
                            if any(strcmp(PlotParms.TwoD,'Y+'))
                                ThisFace  =  Face(6,:)+PtStart;  %OPTIM
                                ThisFaceC = CM(ThisColor,:);
                            end
                            if any(strcmp(PlotParms.TwoD,'Y-'))
                                ThisFace  =  Face(3,:)+PtStart;  %OPTIM
                                ThisFaceC =  CM(ThisColor,:);
                            end
                            if any(strcmp(PlotParms.TwoD,'Z+'))
                                ThisFace  =  Face(4,:)+PtStart;  %OPTIM
                                ThisFaceC =  CM(ThisColor,:);
                            end
                            if any(strcmp(PlotParms.TwoD,'Z-'))
                                ThisFace  =  Face(1,:)+PtStart;  %OPTIM
                                ThisFaceC =  CM(ThisColor,:);
                            end
                        end
                        FList{ThisMat}=[FList{ThisMat}; ThisFace];  %OPTIM
                        CList{ThisMat}=[CList{ThisMat}; ThisFaceC];
                        CVList{ThisMat}=[CVList{ThisMat}; ThisVertC];
                        FAList{ThisMat}=FaceAlpha;
%                        if ~isempty(find(ModelMatrix(Xi,Yi,Zi) == PlotParms.EdgeOnlyMatl, 1))
%                            set(F,'EdgeColor',get(F(1),'facecolor'));
%                            set(F,'facecolor','none');
%                        end
                    end
%                    if ~PlotGeom
%                        MatPatchList{ThisMat}=[MatPatchList{ThisMat} F];
%                    end
                    NoHeat=true;
                    if ~isempty(Q)
                        T='';
                        if iscell(Q)
                            if isempty(Q{Xi,Yi,Zi})
                                ThisQ=0;
                            else
                                ThisQ=Q{Xi,Yi,Zi}(Qt);
                            end
                        else
                            ThisQ=unique(Q(Xi,Yi,Zi,:));
                        end
                        if (~isscalar(ThisQ)) || ThisQ ~=0
                            if isreal(ThisQ)
                                ThisQ=sprintf('%g',ThisQ);
                            else
                                ThisQ=char(ThisQ);
                            end
                            F=patch('faces',ThisFace,'vertices',VList{ThisMat},'facecolor','none');
                            QFList{ThisMat} = [QFList{ThisMat} F];
                            if isKey(QList,ThisQ)
                                QList(ThisQ)=[QList(ThisQ) F];
                            else
                                QList(ThisQ)=F;
                            end
                        end
                        text(mean([X(Xi) X(Xi+1)]), mean([Y(Yi) Y(Yi+1)]), mean([Z(Zi) Z(Zi+1)]),T,'horiz','center')
                    end
                    if ~isempty(PlotParms.EdgeColor) && NoHeat
                        set(F,'EdgeColor',PlotParms.EdgeColor);
    %                        set(F,'facealpha',PlotParms.Transparency);
                    end
                end
            end
        end
    end
%    if PlotGeom
        for Imat=1:length(MatListNumbers) %OPTIM
            if ~isempty(find(MatListNumbers(Imat) == PlotParms.TransMatl, 1))
                FaceAlpha=PlotParms.Transparency;
            end
            EdgeColor='black';
            if ~isempty(PlotParms.EdgeColor) 
                EdgeColor=PlotParms.EdgeColor;
            end
            if ~isempty(find(MatListNumbers(Imat) == PlotParms.EdgeOnlyMatl, 1))
                FaceColor='none';
                EdgeColor='flat';
                ColorList=CList{Imat};
                ColorList=CVList{Imat};
            else
                FaceColor='flat';
                ColorList=CList{Imat};
            end
            
%            ThisColor=find(ColorList==MatListNumbers(Imat));
            F   =patch('faces',FList{Imat},'vertices',VList{Imat}, ...
                        'facevertexcdata',ColorList, ...
                        'facealpha',FaceAlpha, ...
                        'edgecolor', EdgeColor, ...
                        'facecolor',FaceColor, ...
                        'facealpha',FAList{Imat});
                        % 'FaceAlpha',FaceAlpha);
            MatPatchList{Imat}=[F QFList{Imat}];
        end %OPTIM
 %   end
    Xrange=max(X)-min(X);
    Yrange=max(Y)-min(Y);
    Zrange=max(Z)-min(Z);
    Xmid=mean([max(X) min(X)]);
    Ymid=mean([max(Y) min(Y)]);
    Zmid=mean([max(Z) min(Z)]);
    axis equal
   % set(ThisAxis,'visi','off')
    rotate3d(ThisAxis,'on')

    if PlotGeom
        Hoffset=0.5;
        LftT=sprintf('h=%g, T_a=%g',h(Direx.Left),Ta(Direx.Left));
        RgtT=sprintf('h=%g, T_a=%g',h(Direx.Right),Ta(Direx.Right));
        BckT=sprintf('h=%g, T_a=%g',h(Direx.Back),Ta(Direx.Back));
        FrtT=sprintf('h=%g, T_a=%g',h(Direx.Front),Ta(Direx.Front));
        TopT=sprintf('h=%g, T_a=%g',h(Direx.Top),Ta(Direx.Top));
        BtmT=sprintf('h=%g, T_a=%g',h(Direx.Bottom),Ta(Direx.Bottom));
    else
        Hoffset=0.1;
        LftT='';
        RgtT='';
        BckT='';
        FrtT='';
        TopT='';
        BtmT='';
        set(gca,'xtick',[]);
        set(gca,'ytick',[]);
        set(gca,'ztick',[]);
        set(gca,'color','none');
        set(gca,'xcolor','none');
        set(gca,'ycolor','none');
        set(gca,'zcolor','none');
    end
    if not(PlotParms.HideBC)
        T=[];
        T=[T text(min(X)-Hoffset*Xrange,Ymid,Zmid,sprintf('Lft %s',LftT)) ];
        T=[T text(max(X)+Hoffset*Xrange,Ymid,Zmid,sprintf('Rgt %s', RgtT)) ];
        T=[T text(Xmid, min(Y)-Hoffset*Yrange,Zmid,sprintf('Bck %s', BckT)) ];
        T=[T text(Xmid, max(Y)+Hoffset*Yrange,Zmid,sprintf('Frt %s', FrtT)) ];
        T=[T text(Xmid, Ymid, max(Z)+Hoffset*Zrange,sprintf('Top %s', TopT)) ];
        T=[T text(Xmid, Ymid, min(Z)-Hoffset*Zrange,sprintf('Btm %s', BtmT)) ];
        set(T,'edge',[0 0 0]);
    end

    title(PlotTitle)
    set(gca,'visi','on')
    %Display axes in green.
    if PlotParms.PlotAxes
        Xmax=max(max([X Y Z])-min([X Y Z]))*1.1;
        Ymax=Xmax;
        Zmax=Xmax; %max(Z)*1.1;
        L(1)=line([min(X) Xmax], [1 1]*min(Y) , [1 1]*min(Z));
        L(2)=line([1 1]*min(X) , [min(Y) Ymax], [1 1]*min(Z));
        L(3)=line([1 1]*min(X) , [1 1]*min(Y) , [min(Z) Zmax]);
        set(L,'color',[0 1 0], 'linewidth',2)
        text(Xmax,min(Y),min(Z),'X');
        text(min(X),Ymax,min(Z),'Y');
        text(min(X),min(Y),Zmax,'Z');
    end
    
    if PlotParms.ShowExtent
        Delta=(max([X(:); Y(:); Z(:)])-min([X(:); Y(:); Z(:)]))*10^(-4);
        Nx=min(X)-Delta;
        Mx=max(X)+Delta;
        Ny=min(Y)-Delta;
        My=max(Y)+Delta;
        Nz=min(Z)-Delta;
        Mz=max(Z)+Delta;
        Ptch(1)=patch([Nx Nx Mx Mx], [Ny My My Ny], [1 1 1 1]*Nz,1);
        Ptch(2)=patch([Nx Nx Mx Mx], [Ny My My Ny], [1 1 1 1]*Mz,1);
        Ptch(3)=patch([1 1 1 1]*Nx,  [Ny My My Ny], [Nz Nz Mz Mz],1);
        Ptch(4)=patch([1 1 1 1]*Mx,  [Ny My My Ny], [Nz Nz Mz Mz],1);
        Ptch(5)=patch([Nx Nx Mx Mx], [1 1 1 1]*Ny,  [Nz Mz Mz Nz],1);
        Ptch(6)=patch([Nx Nx Mx Mx], [1 1 1 1]*My,  [Nz Mz Mz Nz],1);
        if not(isempty(PlotParms.EdgeColor))
            set(Ptch,'edgecolor',PlotParms.EdgeColor)
        end
        set(Ptch,'facecolor',[0 0 0]);
        set(Ptch,'facealpha',.05);
        
    end

    hold off
 
    pbaspect([1 1 1])
    
    if isempty(PlotParms.TwoD)
        view(45*3, 45*0.5)
    else
        if any(PlotParms.TwoD{1}=='Z')
            view(2)
        elseif any(PlotParms.TwoD{1}=='X')
            view(90,0)
        elseif any(PlotParms.TwoD{1}=='Y')
            view(0,0)
        end
    end
    set(ThisAxis,'unit','normal')
    CB=colorbar;    
    set(CB,'userdata','REMOVE')
    if ~PlotGeom
        ylabel(CB,ColorTitle);
        Scale=linspace(0,1,11);
        set(CB,'ticks',Scale);
        set(CB,'ticklabels',linspace(ValMin,ValMin+ValRange,length(Scale)));
    else
        set(CB,'visible','off')

    end

    if PlotParms.ShowButtons
        DoButtons('init','Names',{matlist{MatListNumbers} 'BCs'},'position',[.75,.9, 0.0, 0],'units','normal',...
                  'colors',[ButtonColors; .9 .9 .9], 'entities',[MatPatchList {T}],'direction','vertical',...
                  'Parent',get(gca,'parent'));
    end

    if ~isempty(Q)
        %CurA=gca;
        P=get(ThisAxis,'posit');
        PBorder=1-(P(3)+P(1));
%        set(ThisAxis,'posit',[PBorder P(2) 1-2*PBorder P(4)]);
        KeyList=keys(QList);
        QColor(:,1)=(length(KeyList):-1:0)/(length(KeyList));
        QColor(:,2)=0;
        QColor(:,3)=0;
        QCB=axes(get(gca,'parent'));
        set(QCB,'userdata','REMOVE');
        set(QCB,'posit',[0 .09 .05 .8]);
        for Ki=1:length(KeyList)
            set(QList(KeyList{Ki}),'EdgeColor',QColor(Ki,:),'linewidth',3);
            rectangle('position',[0,(Ki-1)/length(KeyList),1,1/length(KeyList)],'facecolor',QColor(Ki,:),'userdata','REMOVE');
            BarText=sprintf('%4.2g',-1*str2num(KeyList{Ki}));
            TT=text(1,(Ki-1)/length(KeyList)+.5/length(KeyList),BarText,'horizontalalig','right','rotation',90,'verticalalign','top','userdata','REMOVE');
        end
        set(QCB,'vis','off')
        text(0,0,'Q (W)','vertical','top')
        
        %axes(CurA); %Takes lots of time
    end
    delete(DrawStatus)
    set(ThisAxis,'userdata',PlotParms)
    drawnow
end

function [Val, PV]=Pop(PV) 
    if length(PV)>=1
        Val=PV{1};
    else
        Val={};
    end
    if length(PV)>=2
        PV=PV(2:end);
    else
        PV={};
    end
end

function DoButtons(Action,varargin)
%'Init' the following parameters exist
%  'names'     - cell array of button names
%  'position'  - Positioning of the group of buttons (if H,W=0 will be auto)
%  'units'     - default is 'normal'
%  'color'     - cell array of button colors
%  'entities'  - Handles to entites to be switched on/off
%  'direction' - Buttons arranged vertical or horizontal
%  'parent'    - Handle to parent. Default is gcf

    if (not(isempty(varargin))) && iscell(varargin{1})
        PropValPairs=varargin{1};
    else
        PropValPairs=varargin;
    end
    strleft=@(S,n) S(1:min(n,length(S)));
    
    switch upper(Action)
        case 'INIT'
            Units='normal';
            Position=[0 0 0 0];
            ButtonNames={'1'};
            Color=[];
            Parent=gcf;
            Direction='horizontal';
            while ~isempty(PropValPairs) 
                [Prop, PropValPairs]=Pop(PropValPairs);
                if ~ischar(Prop)
                    error('Property name must be a string.');
                end
                Pl=length(Prop);
                %disp(Prop)
                switch lower(Prop)
                    case strleft('names',Pl)
                        [Value, PropValPairs]=Pop(PropValPairs); 
                        ButtonNames=Value;
                    case strleft('position',Pl)
                        [Value, PropValPairs]=Pop(PropValPairs); 
                        Position=Value;
                    case strleft('units',Pl)
                        [Value, PropValPairs]=Pop(PropValPairs); 
                        Units=Value;
                    case strleft('colors',Pl)
                        [Value, PropValPairs]=Pop(PropValPairs); 
                        Color=Value;
                    case strleft('entities',Pl)
                        [Value, PropValPairs]=Pop(PropValPairs); 
                        Entities=Value;
                    case strleft('direction',Pl)
                        [Value, PropValPairs]=Pop(PropValPairs);
                        Direction=Value;
                    case strleft('parent',Pl)
                        [Value, PropValPairs]=Pop(PropValPairs);
                        Parent=Value;
                    otherwise
                        fprintf('Property "%s" is unknown.\n',Prop)
                end

            end
    end
    MakeButton=@(Name)uicontrol('parent',Parent,'style','togglebutton','min',0,'max',1,'string',Name,'fontweight','bold','units',Units,'value',1);
    if strcmpi(Action,'init')
        TotalWidth=0;
        TotalHeight=0;
        MaxWidth=0;
        %ClearButtons
        OldButtons=get(Parent,'children');
        for I=1:length(OldButtons)
            U=get(OldButtons(I),'user');
            if iscell(U) && strcmpi(U{3},'B613')
                delete(OldButtons(I))
            end
        end
        for I=1:length(ButtonNames)
            ButtonNames{I}=[' ' ButtonNames{I} ' '];
            BH=MakeButton(ButtonNames{I});
            E=get(BH,'extent');
            delete(BH);
            MaxWidth=max(E(3),MaxWidth);
            TotalWidth =TotalWidth +E(3);
            TotalHeight=TotalHeight+E(4);
        end
        if Position(3)==0
            HGap=.01;
            Position(3)=.01;
        else
            HGap=(Position(3)-TotalWidth)/(length(ButtonNames)-1);
        end
        if Position(4)==0
            VGap=.01;
            Position(4)=0.01;
        else
            VGap=(Position(4)-TotalHeight)/(length(ButtonNames)-1);
        end
        CurX=Position(1);
        CurY=Position(2);
        for I=1:length(ButtonNames)
            Toggle=@TogglePanel;
            BH(I)=MakeButton(ButtonNames{I});
            set(BH(I),'callback',Toggle);
            if ~isempty(Color)
                set(BH(I),'backgroundcolor',Color(I,:))
                C=get(BH(I),'backgroundcolor');
                set(BH(I),'foregroundcolor',[1 1 1]-C,'user',{Entities{I} C 'B613'})
            end
            if strcmpi(Direction,'horizontal')
                W=Position(3)-HGap*(length(ButtonNames)-1)/length(ButtonNames);
                H=Position(4);
                Y=Position(2);
                set(BH(I),'position',[CurX Y W H]);
                E=get(BH(I),'extent');
                set(BH(I),'position',[CurX Y-E(4) E(3) E(4)]);
                CurX=CurX+E(3)+HGap;
            else
                W=Position(3)-HGap*(length(ButtonNames)-1)/length(ButtonNames);
                H=Position(4);
                X=Position(1);
                set(BH(I),'position',[X CurY W H]);
                E=get(BH(I),'extent');
                if MaxWidth>Position(3)
                    Position(3)=MaxWidth;
                end
                set(BH(I),'position',[X CurY Position(3) E(4)]);
                CurY=CurY-E(4)-VGap;
            end
        end
    end
end

function TogglePanel(ButtonH,Action)

    %PanelH=get(ButtonH,'parent');
    EntityColor=get(ButtonH,'user');
    Entities =EntityColor{1};
    OrigColor=EntityColor{2};
    
    VisText{1}='off';
    VisText{2}='on';
    
    if get(ButtonH,'value')
        %Values(Index)=1;
        set(ButtonH,'backgroundcolor',OrigColor,'foregroundcolor',[1 1 1]-OrigColor)
        set(Entities,'visible','on');
    else
        %Values(Index)=0;
        set(ButtonH,'backgroundColor',[.9 .9 .9],'foregroundcolor',[0 0 0]);
        set(Entities,'visible','off');
    end
    %set(PanelH,'user',Values)
end
    