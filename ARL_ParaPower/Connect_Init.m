function [A,B,Bexp,Map] = Connect_Init(Mat,h)
% Initializes matrix blocks A, B, and expanded B with connectivity entries implied by
% Mat and h.  
%  A is n x n where n = length(Mat), B is n x m where m is
% number of nonzero h, and Ext = eye(m).  Interior boundary voids, custom
% connectivity, and null materials not handled by this routine.  Connectivity to null boundaries are included in Bexp.

Map=reshape(1:numel(Mat),size(Mat)); %x,y,z


% Convection coefficients for the row=0, row=end+1, col=0, col=end+1, layer=0, and layer=end+1
h1=ones(1,size(Map,2)+2,size(Map,3)); h2=h1;  %dimensions extended for padding
h3=ones(size(Map,1),1,size(Map,3)); h4=h3;
h5=ones(size(Map,1)+2,size(Map,2)+2,1); h6=h5; %dimensions extended for padding

Full=[zeros(numel(Map)) zeros(numel(Map),numel(h))];  %Building [A B]
%Fulli=Full; Fullj=Full; Fullk=Full;  %in case decision to have explicit seperation

padmap=[h1*(numel(Map)+1); [h3*(numel(Map)+3) Map h4*(numel(Map)+4)]; h2*(numel(Map)+2)];
padmap=cat(3,h5*(numel(Map)+5),padmap,h6*(numel(Map)+6));  %extended array containing Mat that allows for indexing

%Build expanded connectivity map
rowup=padmap(3:end,2:end-1,2:end-1);        %Row-wise map of columns of [A B] that need to be 1
rowdown=padmap(1:end-2,2:end-1,2:end-1);    %The ith element (linear indexing) of these vectors
colup=padmap(2:end-1,3:end,2:end-1);        %   contains the column index j of element ij in [A B]
coldown=padmap(2:end-1,1:end-2,2:end-1);    %   that needs a 1
layup=padmap(2:end-1,2:end-1,3:end);
laydown=padmap(2:end-1,2:end-1,1:end-2);


%Here is a "vectorized" routine that is slower.  It was assuming Full was [A B]'
%{
ind_pad=size(Full,1)*[0:size(Full,2)-1]';   %Preparing to offset our Row-wise maps

index_list=cat(1,rowup(:)+ind_pad,rowdown(:)+ind_pad,colup(:)+ind_pad,coldown(:)+ind_pad,layup(:)+ind_pad,laydown(:)+ind_pad);

Full(index_list)=1;         %Our linear indexing effectively proceeds Row-wise across [A B]
Full=Full';                 %Transposing to obtain [A B]
%}


%tic
for n=1:size(Full,1)  %is there a way to vectorize this? Full(:,rowup(:))=1 doesnt work
    Full(n,rowup(n))=1;  %actually plenty fast
    Full(n,rowdown(n))=1;
    Full(n,colup(n))=2;
    Full(n,coldown(n))=2;
    Full(n,layup(n))=3;
    Full(n,laydown(n))=3;
end
%toc

%Full=Fulli & Fullj & Fullk;

A=Full(:,1:numel(Mat));
Bexp=Full(:,numel(Mat)+1:end);
B(:,:)=Bexp(:,h~=0);

if ~issymmetric(A)
    error('Symmetry of A violated')
elseif nnz(Full)/size(Full,1)~=6
    warning('Non-standard connectivity')
end

end