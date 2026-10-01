function in = helperSetSimscapeInitialPose(mdl, q0)
% helperSetSimscapeInitialPose
% Create a SimulationInput object whose initial Simscape joint states
% are set from q0 for an smimport-ed Neuromeka model.
%
% Inputs:
%   mdl : model name, e.g. 'CartesianImpedanceCtrlForUse'
%   q0  : 7x1 joint configuration [rad]
%
% Output:
%   in  : Simulink.SimulationInput with modified initial state

    q0 = q0(:);

    if numel(q0) ~= 7
        error('q0 must be a 7x1 vector.');
    end

    set_param(mdl,'SimulationMode','normal');
    set_param(mdl,'SimulationCommand','update');

    x0 = Simulink.BlockDiagram.getInitialState(mdl);

    for k = 1:x0.numElements
        st = x0.get(k);
        name = st.Name;

        tokQ = regexp(name,'\.joint(\d+)\.Rz\.q$','tokens','once');
        tokW = regexp(name,'\.joint(\d+)\.Rz\.w$','tokens','once');

        if ~isempty(tokQ)
            jointNum = str2double(tokQ{1});
            st.Values.Data = q0(jointNum+1);
            x0 = x0.setElement(k,st);

        elseif ~isempty(tokW)
            st.Values.Data = 0;
            x0 = x0.setElement(k,st);
        end
    end

    in = Simulink.SimulationInput(mdl);
    in = in.setInitialState(x0);
end