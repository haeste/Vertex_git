function [ activation ] = getExtracellularInput(TP, StimParams, t, NeuronModel, NeuronParams)
%Returns a matrix representing the potential change at each compartment
%given the PDE solution and locations of the compartments. Uses the
%activation function.

if isa(TP.StimulationField, 'pde.StationaryResults')
    F = TP.StimulationField;
elseif isa(TP.StimulationField, 'pde.TimeDependentResults')
    F = TP.StimulationField;
else
    F = pdeInterpolant(TP.StimulationField{1},TP.StimulationField{2},TP.StimulationField{3});
end


activation = cell(TP.numGroups,1);
func = 'activation';

for iGroup = 1:TP.numGroups
    point1 = StimParams.compartmentlocations{iGroup,1};
    point2 = StimParams.compartmentlocations{iGroup,2};

    
    numcompartments = length(point1.x(:,1));

    for iComp = 1:numcompartments
        if strcmp(func,'activation')
        activation{iGroup}(iComp,:) = activationfunction([point1.x(iComp,:);point1.z(iComp,:);point1.y(iComp,:)] ,...
            [point2.x(iComp,:); point2.z(iComp,:);point2.y(iComp,:)],...
           F,t);
        elseif strcmp(func,'cable')
            %Get neighbours
        activation{iGroup}(iComp,:) = get_extracellular_current([point1.x(iComp,:);point1.z(iComp,:);point1.y(iComp,:)] ,...
            [point2.x(iComp,:); point2.z(iComp,:);point2.y(iComp,:)],...
           F,t, NeuronModel, NeuronParams,neighbour1,neighbour2,neighbour3);
        elseif strcmp(func,'mirror')
            activation{iGroup}(iComp,:) = mirrorestimate([point1.x(iComp,:);point1.z(iComp,:);point1.y(iComp,:)] ,...
            [point2.x(iComp,:); point2.z(iComp,:);point2.y(iComp,:)],...
           F,t);
        end
    end
    
end

end

