function [ result, model ] = invitroSliceStimAC(geometryloc,stimstrength)
%invitroSliceStim Loads the gemortry and calculates the 

if nargin < 2
    stimstrength = 1; %give a default if stimstrength isn't given as an argument
end

model = createpde;
importGeometry(model,geometryloc);


%Outer, insulating boundaries
applyBoundaryCondition(model,'face',2:5,'g',0.0,'q',0.0); % for the
%initial point stimulation stl

%Electrode-tissue boundary

if isequal(geometryloc,'chrismodelmod9.stl') 
    applyBoundaryCondition(model,'face',[9,14:17],'h',1.0,'r',@myrfun); % r value is the input in mv. This is what to vary to change field strenght
    applyBoundaryCondition(model,'face',[7,10:13],'h',1.0,'r',@myrfun2); % also vary it for this one!
elseif isequal(geometryloc,'topbottomstim4.stl') 
    applyBoundaryCondition(model,'face',[1],'h',1.0,'r',@myrfun); % r value is the input in mv. This is what to vary to change field strenght
    applyBoundaryCondition(model,'face',[6],'h',1.0,'r',@myrfun2); % also vary it for this one!
elseif isequal(geometryloc,'topbottomstim2.stl')
    applyBoundaryCondition(model,'face',[3:6],'g',0.0,'q',0.0); % the outer model boundarys have no change in electric current, so it is always zero here and beyond?
    applyBoundaryCondition(model,'face',[7,8,15:19],'h',1.0,'r',@myrfun); %the 'r' 5.0 sets up a 5(mv?) voltage here
    applyBoundaryCondition(model,'face',[1,2,9:14],'h',1.0,'r',@myrfun2);
elseif isequal(geometryloc,'sidesidestim2.stl')
    applyBoundaryCondition(model,'face',[1:19],'g',0.0,'q',0.0); % the outer model boundarys have no change in electric current, so it is always zero here and beyond?
    applyBoundaryCondition(model,'face',5,'h',1.0,'r',@myrfun); %the 'r' 5.0 sets up a 5(mv?) voltage here
    applyBoundaryCondition(model,'face',3,'h',1.0,'r',@myrfun2);
else % boundaries for the default point stimulation geometry
    applyBoundaryCondition(model,'face',[8,9],'h',1.0,'r',@myrfun);
    applyBoundaryCondition(model,'face',[10,11],'h',1.0,'r',@myrfun2);
end


specifyCoefficients(model,'m',0, 'd',1, 'c',0.2, 'a',0, 'f',0); % the difference here from DC is that d=1, making this time dependent.

%% Set initial conditions
% % this is necessary for a time dependent model
generateMesh(model);
disp(model.IsTimeDependent)

tlist=0:0.2:10;  % this is the list of times to solve for, which would need to be modified for different frequencies, I guess?
% NB: if changing tlist, need to also change 't' in the
% getExtracellularPotential call in simulate: t is equal to the length of
% tlist.

if model.IsTimeDependent
     setInitialConditions(model,0); 
    %first condition after model is u, the state att=0.
    result = solvepde(model,tlist);
 else
    result = solvepde(model);
 end


%% Changing input function

function bcMatrix = myrfun(~,state)

bcMatrix = stimstrength*sin(state.time);

end

function bcMatrix = myrfun2(~,state)

bcMatrix = -stimstrength*sin(state.time);

end

end

