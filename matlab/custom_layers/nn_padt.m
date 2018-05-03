function y = nn_padt(x, crop , dzdy)
%NN_PADT CNN adjoint operation of padding.
%   Y = NN_PADT(X, CROP) performs the adjoint operation of NN_PAD
%   which pads symmetrically the spatial dimensions of the input X.
%   CROP specifies the amount of cropping as [TOP, BOTTOM, LEFT, RIGHT].
%
%   DZDX = NN_PADT(X, CROP, DZDY) computes the derivative DZDX of the
%   function projected on the output derivative DZDY. DZDX has the same
%   dimension as X and DZDY the same dimension as Y.
%
%   DZDX = NN_PADT([], CROP, DZDY) is an alternative to
%   the previous call in which X is omitted.

% stamatis@math.ucla.edu, 06/01/2015


if ~isempty(x)
  sz=size(x);
elseif ~isempty(dzdy)
  sz=size(dzdy);
  sz(1)=sz(1)+crop(1)+crop(2);
  sz(2)=sz(2)+crop(3)+crop(4);
else
  sz=[];
end

if numel(crop)==1
  crop=crop*ones(1,4);
end

if crop(1)+crop(2) > sz(1) || crop(3)+crop(4) > sz(2)
  error('nn_padt:InvalidInput','crop does not appear to have valid values.');
end

if nargin <= 2 || isempty(dzdy)
  x(crop(1)+1:2*crop(1),:,:,:)=...
    x(crop(1)+1:2*crop(1),:,:,:)+x(crop(1):-1:1,:,:,:);
  
  x(end-2*crop(2)+1:end-crop(2),:,:,:)=...
    x(end-2*crop(2)+1:end-crop(2),:,:,:)...
    +x(end:-1:end-crop(2)+1,:,:,:);
  
  x(:,crop(3)+1:2*crop(3),:,:)=...
    x(:,crop(3)+1:2*crop(3),:,:)+x(:,crop(3):-1:1,:,:);
  
  x(:,end-2*crop(4)+1:end-crop(4),:,:)=...
    x(:,end-2*crop(4)+1:end-crop(4),:,:)...
    +x(:,end:-1:end-crop(4)+1,:,:);
  
  y=x(crop(1)+1:end-crop(2),crop(3)+1:end-crop(4),:,:);
else
  sflag=false; % Check for equal-size cropping on TOP-BOTTOM and LEFT-RIGHT
  if crop(1)==crop(2) && crop(3)==crop(4)
    sflag=true;
  end
  
  if sflag
    y=padarray(dzdy,[crop(1),crop(3)],'both','symmetric');
  else
    y = padarray(dzdy,[crop(1),crop(3)],'pre','symmetric');
    y = padarray(y,[crop(2),crop(4)],'post','symmetric');
  end
end


