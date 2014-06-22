function [Image]=rgb_to_gray(Input)
if(size(Input,3)~=3)
    Image=Input;
    return;
end
Image=0.299*Input(:,:,1)+0.587*Input(:,:,2)+0.114*Input(:,:,3);
end
