function [melange]=fusion(a,b,c,d,e,f,g,h,i,j,l1,l2,l3,l4,l5,l6,l7,l8,l9,l10)

m=[l1 l2 l3 l4 l5 l6 l7 l8 l9 l10];
r=min(m);
melange(1,:)=a(1:r);
melange(2,:)=b(1:r);
melange(3,:)=c(1:r);
melange(4,:)=d(1:r);
melange(5,:)=e(1:r);
melange(6,:)=f(1:r);
melange(7,:)=g(1:r);
melange(8,:)=h(1:r);
melange(9,:)=i(1:r);
melange(10,:)=j(1:r);
end