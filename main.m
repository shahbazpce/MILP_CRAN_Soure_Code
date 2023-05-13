%% Description
% This ILP implemenation of two-stage PON of my third journal paper 
% Optimized Design of Multistage Passive Optical Networks- 2012
% Candinate or potential sites of splitter placement is selected from
% k-means++ clustering algorithm
%% clearing and closing window and variables
clc;
clear;
close all;

%% Loading the data from workspace
load('N_25_5km.mat');   % main file loading
onuCordinates = onuPoints;     % cordinates of points i.e.ONU
oltCordinates = olt_points; % cordinates of OLT
RN2_Points = RN2Points;   % RN2 points are second stage points that is close to the ONU
RN1_Points = RN1Points;

%% Calculating distance matrix
% ONU to Remote node distance matrix
distance_RN2ToONU = EuclieanDistCal(onuCordinates,RN2_Points); 
% OLT to Remote node distance matrix

distance_RN1ToRN2 = EuclieanDistCal(RN2_Points, RN1_Points);

distance_OltToRN1 = EuclieanDistCal(RN1_Points,olt_points);

distance_OltToRN2 = EuclieanDistCal(RN2_Points,olt_points);

distance_RN1ToONU = EuclieanDistCal(onuCordinates,RN1_Points);


cost_fiber_trenching = 4000 + 16000;   
cost_olt_port_each = 2500 ; % in dollar
cost_splitter_port = 100;
cost_oltLineCard = 8.9;
cost_opex_port = 400000;
cost_total = cost_olt_port_each + cost_opex_port;
d_max=20;
d_differential = 10; % maximum differential distance 
% %% Cost component taken
% % 1.35 per km of laid fiber (installation and fiber cables), 8.9 per OLT line card,
% % 0.8 per splitter location (equipment and housing) and 136 for OPEX.
% cost_fiber = 1.35;   
% cost_oltLineCard = 8.9;
% cost_spliiter = 0.8;
% cost_opex = 136;
% 
% %% Input parameter
 No_of_ONUs = size(onuCordinates,1);  % total number of ONUs 
 No_of_RN2 = size(RN2_Points,1);  % total number of ONUs 
 No_of_RN1 = size(RN1_Points,1);  % total number of ONUs 
% M = size(rnCordinates,1);% total number of potential sites for splitter placement
% S = 6 ; % splitter types. i.e., base-2 logarithm of the maximum splitting ratio of the PON flavor considered..i.e.(1:64) for S = 6
 a_ji = distance_RN2ToONU*cost_fiber_trenching; %cost_fiber*
 b_kj = distance_RN1ToRN2*cost_fiber_trenching; %cost_fiber*
 c_ki = distance_RN1ToONU*cost_fiber_trenching;
 b_0k = distance_OltToRN1*cost_fiber_trenching;
 delta = 10^6;
% b_i0 = ((cost_fiber*distance_oltToRN)+cost_oltLineCard+cost_spliiter+cost_opex);
% b_ij = cost_fiber*distance_RNToRN;
% for i=1:S
%     d_k (:,i) = cost_spliiter;
% end
% 
%% Formulation Begining
% Main optimization function
fid=fopen('mainOutputFile.txt','w');
fprintf(fid,'Minimize\n\n');
%1

 for j=1:No_of_RN2
    for i= 1:No_of_ONUs

fprintf(fid,' %c %4.4f%c%02d%02d','+',a_ji(j,i) ,'X',j,i);
    end
fprintf(fid,'\n');
end
%2
for k=1:No_of_RN1
    for i= 1:No_of_ONUs

fprintf(fid,' %c %4.4f%c%02d%02d','+',c_ki(k,i) ,'Z',k,i);
    end
fprintf(fid,'\n');
end
for k=1:No_of_RN1
    for j= 1:No_of_RN2
fprintf(fid,' %c %4.4f%c%02d%02d','+',b_kj(k,j) ,'Y',k,j);
    end
fprintf(fid,'\n');
end

%3
for k=1:No_of_RN1
fprintf(fid,' %c %4.4f%c%02d%02d','+',b_0k(k) ,'Y',0,k);
    end
fprintf(fid,'\n');
for k = 1:No_of_RN1
            fprintf(fid,'%s%02d',' + Dmax',k);
 end
% for i= 1:M
% fprintf(fid,' %c %4.4f%c%02d%02d','+',b_i0(i) ,'Y',i,0);
% end
% fprintf(fid,'\n');
% %3
% 
% for i= 1:M
% for j=1:M
%     if i~=j
% fprintf(fid,' %c %4.2f%c%02d%02d','+',b_ij(i,j) ,'Y',i,j);
%     end
% end
% fprintf(fid,'\n');
% end
% %4
% 
% for k= 1:S
% for j=1:M
% fprintf(fid,' %c %0.1f%c%02d%02d','+',d_k(k) ,'Z',j,k);
% end
% fprintf(fid,'\n');
% end
fprintf(fid,'\n\nsubject to\n\n');
%%%%%%%%%%%%%%%%%%%%%%%%%

% %% Constraint_1
% 
% for i= 1:No_of_ONUs
% for j=1:No_of_RN2
% fprintf(fid,' %c %c%02d%02d','+' ,'X',j,i);
% end
% fprintf(fid,' = 1\n');
% end
% fprintf(fid,'\n');
%% Constraint_1

for i= 1:No_of_ONUs
for j=1:No_of_RN2
fprintf(fid,' %c %c%02d%02d','+' ,'X',j,i);
end
for k=1:No_of_RN1
fprintf(fid,' %c %c%02d%02d','+' ,'Z',k,i);
end
fprintf(fid,' = 1\n');
end
fprintf(fid,'\n');
%% Constraint_2
for j= 1:No_of_RN2
for k=1:No_of_RN1
fprintf(fid,' %c %c%02d%02d','+' ,'Y',k,j);
end
fprintf(fid,' <= 1\n');
end
fprintf(fid,'\n');
%% Constraint_3
for j=1:No_of_RN2  
for i= 1:No_of_ONUs
fprintf(fid,' %c %c%02d%02d','+' ,'X',j,i);
end
for k=1:No_of_RN1
fprintf(fid,' %c %d%c%02d%02d','-' ,99999,'Y',k,j);
end
fprintf(fid,' <= 0\n');
end
fprintf(fid,'\n');

%% Constraint_4
for k=1:No_of_RN1
for j=1:No_of_RN2
fprintf(fid,' %c %c%02d%02d','+' ,'Y',k,j);
end
for i=1:No_of_ONUs
fprintf(fid,' %c %c%02d%02d','+' ,'Z',k,i);
end
fprintf(fid,' %c %d%c%02d%02d','-' ,99999,'Y',0,k);

fprintf(fid,' <= 0\n');
end
fprintf(fid,'\n');

% %%Constraint_5 binary eqivalence
% for k = 1:No_of_RN1
%       for j = 1:No_of_RN2
%        for i = 1:No_of_ONUs
%           fprintf(fid,' %c %d%c%02d%02d%02d','+',99999,'T',k,j,i);
%        end
%           fprintf(fid,' %c %c%02d%02d','-','Y',k,j);
%           fprintf(fid,' >= 0\n');
%        end
%       
% end
% fprintf(fid,'\n');
% 
% %%Constraint_6 binary eqivalence
% 
% for k = 1:No_of_RN1
%       for j = 1:No_of_RN2
%        for i = 1:No_of_ONUs
%           fprintf(fid,' %c %c%02d%02d%02d','+','T',k,j,i);
%        end
%           fprintf(fid,' %c %c%02d%02d','-','Y',k,j);
%           fprintf(fid,' <= 0\n');
%        end
%       
% end
% fprintf(fid,'\n');
% 
% %%Constraint_7 binary eqivalence
% 
% 
% for j = 1:No_of_RN2
%        for i = 1:No_of_ONUs
%            for k = 1:No_of_RN1
%           fprintf(fid,' %c %d%c%02d%02d%02d','+',99999,'T',k,j,i);
%            end
%           fprintf(fid,' %c %c%02d%02d','-','X',j,i);
%           fprintf(fid,' <= 0\n');
%        end
%       
% end
% fprintf(fid,'\n');
% 
%%Constraint_8 binary eqivalence

for k = 1:No_of_RN1
       for j = 1:No_of_RN2
           for i = 1:No_of_ONUs
          fprintf(fid,' %c %c%02d%02d','+','Y',k,j);
          fprintf(fid,' %c %c%02d%02d','+','X',j,i);
          fprintf(fid,' %c %c%02d%02d%02d','-','T',k,j,i);
          fprintf(fid,' <= 1\n');
            end
       end
end
fprintf(fid,'\n');
%%Constraint_9 binary eqivalence

for k = 1:No_of_RN1
       for j = 1:No_of_RN2
           for i = 1:No_of_ONUs
          fprintf(fid,' %c %c%02d%02d%02d','+','T',k,j,i);
          fprintf(fid,' %c %c%02d%02d','-','Y',k,j);
          fprintf(fid,' <= 0\n');
            end
       end
end
fprintf(fid,'\n');
%%Constraint_9 binary eqivalence

for k = 1:No_of_RN1
       for j = 1:No_of_RN2
           for i = 1:No_of_ONUs
          fprintf(fid,' %c %c%02d%02d%02d','+','T',k,j,i);
          fprintf(fid,' %c %c%02d%02d','-','X',j,i);
          fprintf(fid,' <= 0\n');
            end
       end
end
fprintf(fid,'\n');

%% Constraint_8
for k= 1:No_of_RN1
for j= 1:No_of_RN2
    for i=1:No_of_ONUs
fprintf(fid,' %c %s%02d%02d','+', 'Dmax',k); 
fprintf(fid,' %c %4.4f%c%02d%02d%02d','-',(distance_OltToRN1(k)+ distance_RN1ToRN2(k,j)...
    + distance_RN2ToONU(j,i)) ,'T',k,j,i);
fprintf(fid,' %c %4.4f%c%02d%02d%02d','-',(distance_OltToRN1(k)+ distance_RN1ToONU(k,i)) ,'Z',k,i);
fprintf(fid,' %c %d%c%02d%02d','+',delta, 'Q',0,k); 
%fprintf(fid,' %s %4.4f%c%02d%02d','>=',(distance_oltToRN(j)+ distance_onuToRN (i,j)));
% fprintf(fid,'\n');
 fprintf(fid,' >= 0\n');
    end
end
end
%fprintf(fid,' %c %d','-',N_olt_port);
fprintf(fid,'\n');
%% Constraint_8
for k= 1:No_of_RN1
for j= 1:No_of_RN2
    for i=1:No_of_ONUs
fprintf(fid,' %c %s%02d%02d','+', 'Dmin',k); 
fprintf(fid,' %c %4.4f%c%02d%02d%02d','-',(distance_OltToRN1(k)+ distance_RN1ToRN2(k,j)...
    + distance_RN2ToONU(j,i)) ,'T',k,j,i);
fprintf(fid,' %c %4.4f%c%02d%02d%02d','-',(distance_OltToRN1(k)+ distance_RN1ToONU(k,i)) ,'Z',k,i);
fprintf(fid,' %c %d%c%02d%02d','-',delta, 'Q',0,k); 
%fprintf(fid,' %s %4.4f%c%02d%02d','>=',(distance_oltToRN(j)+ distance_onuToRN (i,j)));
% fprintf(fid,'\n');
 fprintf(fid,' <= 0\n');
    end
end
end
%fprintf(fid,' %c %d','-',N_olt_port);
fprintf(fid,'\n');
%% Constraint_9

for k= 1:No_of_RN1
fprintf(fid,' %c %c%02d%02d','+','Y',0,k); 
fprintf(fid,' %c %d%c%02d%02d','+',delta, 'Q',0,k); 
fprintf(fid,' <= %d\n',delta);
end
%fprintf(fid,' %c %d','-',N_olt_port);
fprintf(fid,'\n');
%% Constraint
 for k= 1:No_of_RN1
    
          fprintf(fid,'%c %s%02d','+','Dmax',k);
          fprintf(fid,' %c %d%c%02d%02d','-',d_max,'Y',0,k);
          fprintf(fid,' <= 0\n');
 end
 %% Constraint_10

 for k = 1:No_of_RN1
    
          fprintf(fid,'%c %s%02d','+','Dmax',k);
          fprintf(fid,' %c %s%02d','-','Dmin',k); 
          fprintf(fid,' %c %d%c%02d%02d','-',d_differential,'Y',0,k);
          fprintf(fid,' <= 0\n');
          
 end
  fprintf(fid,'\n');
   %% binary variable declaration
  fprintf(fid,'\nbounds\n\n');
  for k = 1:No_of_RN1
            fprintf(fid,'%s%02d','Dmax',k);
             fprintf(fid,' >= 0\n');
  end
 for k = 1:No_of_RN1    
          fprintf(fid,'%s%02d','Dmin',k);
            fprintf(fid,' >= 0\n');
 end
  fprintf(fid,'\nbinary\n\n');
  for j = 1:No_of_RN2
      for i = 1:No_of_ONUs
          fprintf(fid,'%c%02d%02d\n','X',j,i);
      end
  end
   for k = 1:No_of_RN1
      for j = 1:No_of_RN2
 
          fprintf(fid,'%c%02d%02d\n','Y',k,j);
      
      end
   end
   
    for k = 1:No_of_RN1     
          fprintf(fid,'%c%02d%02d\n','Y',0,k);    
    end
     for k = 1:No_of_RN1     
          fprintf(fid,'%c%02d%02d\n','Q',0,k);    
    end
   for k = 1:No_of_RN1
      for j = 1:No_of_RN2
       for i = 1:No_of_ONUs
          fprintf(fid,'%c%02d%02d%02d\n','T',k,j,i);
       end
      
      end
   end
   fprintf(fid,'\n\nend\n\n');

   fclose(fid);
% %% Constraint_2
% for i= 1:M
% for j=0:M
%     if(i~=j)
% fprintf(fid,' %c %c%02d%02d','+' ,'Y',i,j);
%     end
% end
% fprintf(fid,' <= 1\n');
% end
% fprintf(fid,'\n');
% 
% %% Constraint_3
% for j= 1:M
% for i=1:M
%     if(i~=j)
% fprintf(fid,' %c %c%02d%02d','+' ,'Y',i,j);
%     end
% end
% for i=1:N
%     fprintf(fid,' %c %c%02d%02d','+' ,'X',i,j);
% end
% for k=1:S
%     fprintf(fid,' %c %d%c%02d%02d','-',2^k ,'Z',j,k);
% end
% fprintf(fid,' <= 0\n');
% end
% fprintf(fid,'\n\n');
% 
% %% Constraint_4
% 
% for i= 1:M
% for j=0:M
%     if i~=j
% fprintf(fid,' %c %c%02d %c %c%02d %c %d%c%02d%02d',...
% '+' ,'C',i,'-' ,'C',j,'+',99999,'Y',i,j);
% fprintf(fid,' <= 99998\n');
% end
% end
% end
% fprintf(fid,'\n\n');
% 
% %% Constraint_5
% for i= 1:M
%     fprintf(fid,' %c %c%02d','+' ,'C',i);
% for j=0:M
%     if(i~=j)
% fprintf(fid,' %c %d%c%02d%02d','-' ,S,'Y',i,j);
%     end
%   
% 
% end
%   fprintf(fid,' <= 0\n');
% end
% fprintf(fid,'\n');
% 
% %% Constraint_extra
% fprintf(fid,' %c %c%02d %c %d','+' ,'C',0,'=',S+1);
% fprintf(fid,'\n\n');
% 
% %% Constraint_7
% for i = 1:M
%     for j = 0:M
%  if i~=j
% fprintf(fid,' %c %c%02d %c %c%02d %c %d%c%02d%02d',...
% '+' ,'C',i,'-' ,'C',j,'+',99999,'Y',i,j);
% for k=1:S
%     fprintf(fid,' %c %d%c%02d%02d','+',k,'Z',i,k);
% 
% end
% fprintf(fid,' <= 99999\n');
%   end
%     end
% end
% fprintf(fid,'\n\n');
% 
% %% Constraint_8
% 
% for i= 1:M
% for j=0:M
%     if i~=j
% fprintf(fid,' %c %c%02d %c %c%02d %c %d%c%02d%02d',...
% '+' ,'C',i,'-' ,'C',j,'-',99999,'Y',i,j);
% for k=1:S
%     fprintf(fid,' %c %d%c%02d%02d','+',k,'Z',i,k);
% 
% end
% fprintf(fid,' >= -99999\n');
%     end
% end
% end
% fprintf(fid,'\n');
% 
% %% constraint_9
% 
% for j=1:M
%     for i=1:N
%         fprintf(fid,' %c %c%02d%02d','+','X',i,j);
%     end
%      for i = 1:M
%             if i~=j
%                 fprintf(fid,' %c %c%02d%02d','+','Y',i,j);
%             end
%      end
%          for i = 0:M
%                if i~=j
%                  fprintf(fid,' %c %d%c%02d%02d','-',99999,'Y',j,i);
%                end
%          end
% %     end
%     fprintf(fid,' <= 0 \n');
% end
% fprintf(fid,'\n\n');
% 
% %% Constraint_10
% 
% for i = 1:M
%     for j = 0:M
%         if i~=j
%             fprintf(fid,' %c %c%02d%02d','+','Y',i,j);
%         end
%     end
%     fprintf(fid,' %c %c%02d %c%c %d\n','-','C',i,'<','=',0);
%     
% end
%   fprintf(fid,'\n');
%   %% Constraint_11
%   
%   for i = 1:M
%       for k = 1: S
%           fprintf(fid,' %c %c%02d%02d','+','Z',i,k);
%       end
%       fprintf(fid,' <= 1\n');
%   end
%     fprintf(fid,'\n');
% fprintf(fid,'\n\n');
%    %% binary variable declaration
%   
%   fprintf(fid,'binary\n\n');
%   for i = 1:N
%       for j = 1:M
%           fprintf(fid,'%c%02d%02d\n','X',i,j);
%       end
%   end
%    for i = 1:M
%       for j = 0:M
%           if i~=j
%           fprintf(fid,'%c%02d%02d\n','Y',i,j);
%            end
%       end
%    end
%     for i = 1:M
%       for k = 1:S
%          
%           fprintf(fid,'%c%02d%02d\n','Z',i,k);
%           
%       end
%     end
%     fprintf(fid,'\ngeneral\n\n');
%     for i = 1:M
%       
%           fprintf(fid,'%c%02d\n','C',i);
%           
%     end
%     
%    fprintf(fid,'\n\nend\n\n');
% 
%    fclose(fid);
% 
%   
%  %% Plot   
% CV    = '+r+b+c+m+k+yorobocomokoysrsbscsmsksy';       % Color Vector
% clf
% figure(1)
% hold on
%                          % Find points of each cluster    
% %plot(onuCordinates(:,1),onuCordinates(:,2),'*b','LineWidth',2);    % Plot points with determined color and shape
% plot(oltCordinates(:,1),oltCordinates(:,2),'*k','LineWidth',7);       % Plot cluster centers
% %plot(rnCordinates(:,1),rnCordinates(:,2),'*b','LineWidth',7);   
%  for i = 1:length(onuCordinates)
%       plot(onuCordinates(i,1),onuCordinates(i,2),'r+');
% %      % Label the points with the index
%       text(points(i,1),points(i,2),num2str(i));
%  end
%  for i = 1:length(rnCordinates)
%       plot(rnCordinates(i,1),rnCordinates(i,2),'b+');
% %      % Label the points with the index
%       text(rnCordinates(i,1),rnCordinates(i,2),num2str(i));
%  end
% hold off
% grid on
% 
% Drawing the points and blocks graphically
scatter(onuCordinates(:,1),onuCordinates(:,2),'b','MarkerFaceColor',[0 0 0.5]);
hold on;
scatter(olt_points(:,1),olt_points(:,2),'filled','s','MarkerFaceColor',[0 0.5 .9]);
for i = 1:length(onuCordinates)
     
     % Label the points with the index
     text(onuCordinates(i,1),onuCordinates(i,2),num2str(i));
end
for i = 1:length(RN2_Points)
      plot(RN2_Points(i,1),RN2_Points(i,2),'r+');
     % Label the points with the index
     text(RN2_Points(i,1),RN2_Points(i,2),num2str(i));
end
for i = 1:length(RN1_Points)
      plot(RN1_Points(i,1),RN1_Points(i,2),'bs');
     % Label the points with the index
     text(RN1_Points(i,1),RN1_Points(i,2),num2str(i));
end
xlim([0 10]);
ylim([0 10]);
%plot_sq(square_bounds, count_square);
%
