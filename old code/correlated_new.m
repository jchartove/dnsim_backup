%shared pool of spikes
%if there are inhibitory synapses, do we get gamma?
%is rhythmic input more effective at rescuing firing rate?
%what effect does it have on output?
%histc
%use logical and to make sure synchronous spikes aren't from same cell
%or convolve with a square bin
%plot voltages for a good spike pair result

clear;
T0 = 5000;  %3000 millisecond long trial
dt = .005;
T = floor(T0/dt);
t = (1:T)*dt;
no_cells = 2;
p_gj = 1; %probability of gap junction between any pair of cells. should be 1 if you're using 2 cells

no_e_inputs = 127*no_cells; %127 = number of AMPA input synapses per cell in Hjorth et al, times 10 cells
e_size = 0.0053;  %changes magnitude of input. 0.0053 gets you between 5 and 2 Hz firing rate.
%you stop getting firing rate decreases as conductance increases for 10 cells around 0.015. 
%at around 0.5 you can get increased spike pairs with increased conductance in 10 cell networks, but firing rate is deeply weird

no_i_inputs = 93*no_cells; % = 93 times 10
i_size = 0.0053;

tau_i1 = 1; tau_ir = 0.5; tau_id = 5; tau_i = 10; tau_r = 1;
tau_e1 = 1; tau_er = 0.5; tau_ed = 2;
delta_t = 5; %number of milliseconds between two spikes to consider them "synchronous"

max_j = 10; %number of trials to run
max_k = 10; %number of correlation values to use

gap_conductance = (0.025/no_cells);
%rhythmicity = zeros(10,10,20000,10);

firing_rate = zeros(max_k,max_j);
spike_pairs = zeros(max_k, max_j);
firing_avg = zeros(max_k,1);
pair_avg = zeros(max_k, max_j);
spike_indicator = zeros(no_cells,(T0/dt)-1);

for j = 1:max_j
    
    for k = 1:max_k
   
		fraction_shared = (1/(max_k-1))*(k-1);
		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
		e_rate = 2; % presynaptic firing rate (Hz) in Hjorth et al
		e_spikes = rand(no_e_inputs,length(t));
		e_spikes = e_spikes < (1-fraction_shared)*e_rate*dt/1000;
    
		% EPSP for spikes at time t = 0.
		epsp = tau_i*(exp(-max(t - tau_e1,0)/tau_ed) - exp(-max(t - tau_e1,0)/tau_er))/(tau_ed - tau_er);
		epsp = epsp(epsp > eps);    %?
		epsp = [zeros(1,length(epsp)) epsp]; %?
	
		CE_e = repmat(eye(no_cells), 1, no_e_inputs/no_cells);
		e_spike_arrivals = CE_e*e_spikes; % Calculating presynaptic spikes for each cell.
		epsps = nan(size(e_spike_arrivals)); % Calculating EPSP experienced by each cell.
		for c = 1:no_cells
			epsps(c,:) = e_size*conv(e_spike_arrivals(c,:),epsp,'same');
		end
    
		i_rate = 2;
		i_spikes = rand(no_i_inputs,length(t));
		i_spikes = i_spikes < (1-fraction_shared)*i_rate*dt/1000;
    
		% IPSP for spikes at time t = 0.
		ipsp = tau_i*(exp(-max(t - tau_i1,0)/tau_id) - exp(-max(t - tau_i1,0)/tau_ir))/(tau_id - tau_ir);
		ipsp = ipsp(ipsp > eps);
		ipsp = [zeros(1,length(ipsp)) ipsp];
	
		CE_i = repmat(eye(no_cells), 1, no_i_inputs/no_cells);    %Define connectivity from inputs to cells.
		i_spike_arrivals = CE_i*i_spikes; % Calculating presynaptic spikes for each cell.
		ipsps = nan(size(i_spike_arrivals)); % Calculating IPSP experienced by each cell.
		for c = 1:no_cells
			ipsps(c,:) = i_size*conv(i_spike_arrivals(c,:),ipsp,'same');
		end
	
		%shared input
		shared_e_spikes = rand((no_e_inputs/no_cells),length(t));
		shared_e_spikes = shared_e_spikes < (fraction_shared)*e_rate*dt/1000;
		shared_e_arrivals = CE_e(1,:)*(repmat(shared_e_spikes,no_cells,1));
		shared_e_input = nan(size(shared_e_arrivals)); % Calculating EPSP experienced by each cell. %?
		shared_e_input= e_size*conv(shared_e_arrivals,epsp,'same');  %?
    
		shared_i_spikes = rand((no_i_inputs/no_cells),length(t));
		shared_i_spikes = shared_i_spikes < (fraction_shared)*i_rate*dt/1000;
		shared_i_arrivals = CE_i(1,:)*(repmat(shared_i_spikes,no_cells,1));
		shared_i_input = nan(size(shared_i_arrivals)); % Calculating IPSP experienced by each cell. %?
		shared_i_input= i_size*conv(shared_i_arrivals,ipsp,'same');  %?
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
		%for i = 1:no_cells, epsps(i, :) = fraction_shared*shared_e_input + (1-fraction_shared)*epsps(i,:); end
        %for i = 1:no_cells, ipsps(i, :) = fraction_shared*shared_i_input + (1-fraction_shared)*ipsps(i,:); end
		
		for i = 1:no_cells, epsps(i, :) = shared_e_input + epsps(i,:); end
        for i = 1:no_cells, ipsps(i, :) = shared_i_input + ipsps(i,:); end
    
		[Vs,Vd,s,m,h,n,t] = ing_w_dendritic_gap_jxn(no_cells, epsps-ipsps, T0, [], zeros(no_cells), gap_conductance*(rand(no_cells) < p_gj));
		%rhythmicity(k,j,:,:) = abs(fft(Vs'));
		firing_rate(k,j) = 0;

		for a = 1:no_cells
			Vs_pos = Vs > 0;
			Vs_sign_change = diff(Vs_pos(a,:), [], 2);
			spike_indicator(a,:) = Vs_sign_change == 1;
			firing_rate(k,j) = firing_rate(k,j) + sum(spike_indicator(a,:));
            synch_indicator = sum(spike_indicator);
			for d = 1:((T0/dt)-(delta_t/dt)-1)
                synch = sum(synch_indicator(d:d+(delta_t/dt)));
                if synch > 0
                    synch = synch-1;
                end
                spike_pairs(k,j) = spike_pairs(k,j) + synch;
            end
        end
        firing_rate(k,j) = (firing_rate(k,j)/no_cells)*(1000/T0)
    end
    firing_avg = sum(firing_rate,2)/max_j
    spike_pairs = spike_pairs/firing_rate;
	pair_avg = sum(spike_pairs,2)/max_j
end

%for i = 1:5
%    for j = 1:10
%        subplot(10,1,i)
%        plot(squeeze(rhythmicity(i,j,:,:)))
%    end
%end