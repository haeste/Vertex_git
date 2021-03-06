function [NeuronModel, SynModel, InModel] = ...
  groupUpdateSchedule(NP,SS,NeuronModel,SynModel,InModel,iGroup)

% add function to update capacitance? if statement to ignore if there isn't
% a fus flag

% update synaptic conductances/currents according to buffers
for iSyn = 1:size(SynModel, 2)
  if ~isempty(SynModel{iGroup, iSyn})
    updateBuffer(SynModel{iGroup, iSyn});
    updateSynapses(SynModel{iGroup, iSyn}, NeuronModel{iGroup}, SS.timeStep);
  end
end

% update axial currents
if NP(iGroup).numCompartments > 1
  updateI_ax(NeuronModel{iGroup}, NP(iGroup)); % a method of the NeuronModel class
end

% update inputs
if ~isempty(InModel)
  for iIn = 1:size(InModel, 2)
    if ~isempty(InModel{iGroup, iIn})
      updateInput(InModel{iGroup, iIn}, NeuronModel{iGroup}); % need to add an additional input for calculating fus input?
    % updateInput is a method of the InputModel classes
    end
  end
end

% update neuron model variables
if ~isempty(InModel)
  updateNeurons(NeuronModel{iGroup}, InModel(iGroup, :), ...
                NP(iGroup), SynModel(iGroup, :), SS.timeStep);
else
  updateNeurons(NeuronModel{iGroup}, [], ...
                NP(iGroup), SynModel(iGroup, :), SS.timeStep);
end