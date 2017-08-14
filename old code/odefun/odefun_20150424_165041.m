function [Y,T] = odefun_20150424_165041
tspan=[0 200]; dt=0.01;
T=tspan(1):dt:tspan(2); nstep=length(T);
fileID = 1; nreports = 5; enableLog = 1:(nstep-1)/nreports:nstep;enableLog(1) = [];
fprintf('\nSimulation interval: %g-%g\n',tspan);fprintf('Starting integration (euler, dt=%g)\n',dt);soma_soma_iSYN_width = inf;
soma_soma_iSYN_Nmax = max((20),(20));
soma_soma_iSYN_srcpos = linspace(1,soma_soma_iSYN_Nmax,(20))'*ones(1,(20));
soma_soma_iSYN_dstpos = (linspace(1,soma_soma_iSYN_Nmax,(20))'*ones(1,(20)))';
soma_soma_iSYN_netcon = rand((20),(20))<(0.3);
soma_soma_iSYN_netcon = soma_soma_iSYN_netcon.*(1-eye((20)));
dendrite_soma_iCOM_compcon = eye((1),(20));
dendrite_iMultiPoissonExp_Ge = multi_Poisson((1),(127),(2),(10),(1),2,.5,(2000),(0.01));
dendrite_iMultiPoissonExp_Gi = multi_Poisson((1),(73),(2),(10),(1),5,.5,(2000),(0.01));
soma_dendrite_iCOM_compcon = eye((20),(1));
dendrite_dendrite_iGAP_UB = max((1),(1));
dendrite_dendrite_iGAP_Xpre = linspace(1,dendrite_dendrite_iGAP_UB,(1))'*ones(1,(1));
dendrite_dendrite_iGAP_Xpost = (linspace(1,dendrite_dendrite_iGAP_UB,(1))'*ones(1,(1)))';
dendrite_dendrite_iGAP_mask = rand((1),(1))<(0.3);
dendrite_dendrite_iGAP_mask = dendrite_dendrite_iGAP_mask.*(1-eye((1)));
soma_K_an = @(soma_v) .01*(soma_v+55)./(1-exp(-(soma_v+55)/10));
soma_K_bn = @(soma_v) .125*exp(-(soma_v+65)/80);
soma_K_ik = @(soma_v,soma_K_n) (36)*(soma_K_n.^4).*(soma_v-(-77));
soma_Na_am = @(soma_v) .1*(soma_v+40)./(1-exp(-(soma_v+40)/10));
soma_Na_bm = @(soma_v) 4*exp(-(soma_v+65)/18);
soma_Na_ah = @(soma_v) .07*exp(-(soma_v+65)/20);
soma_Na_bh = @(soma_v) 1./(1+exp(-(soma_v+35)/10));
soma_Na_ina = @(soma_v,soma_Na_m,soma_Na_h) (120)*soma_Na_h.*(soma_Na_m.^3).*(soma_v-(50));
soma_leak_ileak = @(soma_v) (0.3)*(soma_v-(-54.4));
soma_soma_iSYN_ISYN = @(V,soma_soma_iSYN_s) (((0.3)/((20)*(0.3))).*(soma_soma_iSYN_netcon*soma_soma_iSYN_s).*(V-(-85)));
dendrite_soma_iCOM_dV = @(IN,OUT) ((IN*ones(1,size(IN,1)))'-(OUT*ones(1,size(OUT,1))));
dendrite_soma_iCOM_ICOM = @(IN,OUT) (0.15).*sum((((IN*ones(1,size(IN,1)))'-(OUT*ones(1,size(OUT,1))))).*dendrite_soma_iCOM_compcon,2);
dendrite_K_an = @(dendrite_v) .01*(dendrite_v+55)./(1-exp(-(dendrite_v+55)/10));
dendrite_K_bn = @(dendrite_v) .125*exp(-(dendrite_v+65)/80);
dendrite_K_ik = @(dendrite_v,dendrite_K_n) (3.6)*(dendrite_K_n.^4).*(dendrite_v-(-77));
dendrite_Na_am = @(dendrite_v) .1*(dendrite_v+40)./(1-exp(-(dendrite_v+40)/10));
dendrite_Na_bm = @(dendrite_v) 4*exp(-(dendrite_v+65)/18);
dendrite_Na_ah = @(dendrite_v) .07*exp(-(dendrite_v+65)/20);
dendrite_Na_bh = @(dendrite_v) 1./(1+exp(-(dendrite_v+35)/10));
dendrite_Na_ina = @(dendrite_v,dendrite_Na_m,dendrite_Na_h) (12)*dendrite_Na_h.*(dendrite_Na_m.^3).*(dendrite_v-(50));
dendrite_input_I = @(t) 10;
dendrite_leak_ileak = @(dendrite_v) (0.03)*(dendrite_v-(-54.4));
dendrite_iMultiPoissonExp_Gte = @(t) (0.1).*dendrite_iMultiPoissonExp_Ge(:,max(1,round(t/(0.01))));
dendrite_iMultiPoissonExp_Gti = @(t) (0.1).*dendrite_iMultiPoissonExp_Gi(:,max(1,round(t/(0.01))));
dendrite_iMultiPoissonExp_Itrain_e = @(t,dendrite_v) ((0.1).*dendrite_iMultiPoissonExp_Ge(:,max(1,round(t/(0.01))))).*(dendrite_v - (0));
dendrite_iMultiPoissonExp_Itrain_i = @(t,dendrite_v) ((0.1).*dendrite_iMultiPoissonExp_Gi(:,max(1,round(t/(0.01))))).*(dendrite_v - (-85));
dendrite_iMultiPoissonExp_Itrain = @(t,dendrite_v) (((0.1).*dendrite_iMultiPoissonExp_Ge(:,max(1,round(dendrite_v/(0.01))))).*(dendrite_v - (0))) + (((0.1).*dendrite_iMultiPoissonExp_Gi(:,max(1,round(dendrite_v/(0.01))))).*(dendrite_v - (-85)));
soma_dendrite_iCOM_dV = @(IN,OUT) ((IN*ones(1,size(IN,1)))'-(OUT*ones(1,size(OUT,1))));
soma_dendrite_iCOM_ICOM = @(IN,OUT) (0.15).*sum((((IN*ones(1,size(IN,1)))'-(OUT*ones(1,size(OUT,1))))).*soma_dendrite_iCOM_compcon,2);
dendrite_dendrite_iGAP_IGAP = @(V1,V2) ((0)/((0.3)*(1))).*sum(((V1*ones(1,size(V1,1)))'-(V2*ones(1,size(V2,1)))).*dendrite_dendrite_iGAP_mask,2);
soma_v = zeros(20,nstep);
soma_v(:,1) = [-65 -65 -65 -65 -65 -65 -65 -65 -65 -65 -65 -65 -65 -65 -65 -65 -65 -65 -65 -65];
soma_K_n = zeros(20,nstep);
soma_K_n(:,1) = [0.317       0.317       0.317       0.317       0.317       0.317       0.317       0.317       0.317       0.317       0.317       0.317       0.317       0.317       0.317       0.317       0.317       0.317       0.317       0.317];
soma_Na_m = zeros(20,nstep);
soma_Na_m(:,1) = [0.052       0.052       0.052       0.052       0.052       0.052       0.052       0.052       0.052       0.052       0.052       0.052       0.052       0.052       0.052       0.052       0.052       0.052       0.052       0.052];
soma_Na_h = zeros(20,nstep);
soma_Na_h(:,1) = [0.596       0.596       0.596       0.596       0.596       0.596       0.596       0.596       0.596       0.596       0.596       0.596       0.596       0.596       0.596       0.596       0.596       0.596       0.596       0.596];
soma_soma_iSYN_s = zeros(20,nstep);
soma_soma_iSYN_s(:,1) = [0.1         0.1         0.1         0.1         0.1         0.1         0.1         0.1         0.1         0.1         0.1         0.1         0.1         0.1         0.1         0.1         0.1         0.1         0.1         0.1];
dendrite_v = zeros(1,nstep);
dendrite_v(1) = [-65];
dendrite_K_n = zeros(1,nstep);
dendrite_K_n(1) = [0.317];
dendrite_Na_m = zeros(1,nstep);
dendrite_Na_m(1) = [0.052];
dendrite_Na_h = zeros(1,nstep);
dendrite_Na_h(1) = [0.596];
tstart = tic;
for k=2:nstep
  t=T(k-1);
  F=((-((36)*(soma_K_n(:,k-1).^4).*(soma_v(:,k-1)-(-77))))+((-((120)*soma_Na_h(:,k-1).*(soma_Na_m(:,k-1).^3).*(soma_v(:,k-1)-(50))))+((-((0.3)*(soma_v(:,k-1)-(-54.4))))+((-((((0.3)/((20)*(0.3))).*(soma_soma_iSYN_netcon*soma_soma_iSYN_s(:,k-1)).*(soma_v(:,k-1)-(-85)))))+((((0.15).*sum((((dendrite_v(k-1)*ones(1,size(dendrite_v(k-1),1)))'-(soma_v(:,k-1)*ones(1,size(soma_v(:,k-1),1))))).*dendrite_soma_iCOM_compcon,2)))+0)))))/(1);
  soma_v(:,k) = soma_v(:,k-1) + dt*F;
  F=(.01*(soma_v(:,k-1)+55)./(1-exp(-(soma_v(:,k-1)+55)/10))).*(1-soma_K_n(:,k-1))-(.125*exp(-(soma_v(:,k-1)+65)/80)).*soma_K_n(:,k-1);
  soma_K_n(:,k) = soma_K_n(:,k-1) + dt*F;
  F=(.1*(soma_v(:,k-1)+40)./(1-exp(-(soma_v(:,k-1)+40)/10))).*(1-soma_Na_m(:,k-1))-(4*exp(-(soma_v(:,k-1)+65)/18)).*soma_Na_m(:,k-1);
  soma_Na_m(:,k) = soma_Na_m(:,k-1) + dt*F;
  F=(.07*exp(-(soma_v(:,k-1)+65)/20)).*(1-soma_Na_h(:,k-1))-(1./(1+exp(-(soma_v(:,k-1)+35)/10))).*soma_Na_h(:,k-1);
  soma_Na_h(:,k) = soma_Na_h(:,k-1) + dt*F;
  F=-soma_soma_iSYN_s(:,k-1)./(1) + ((1-soma_soma_iSYN_s(:,k-1))/(0.25)).*(1+tanh(soma_v(:,k-1)/10));
  soma_soma_iSYN_s(:,k) = soma_soma_iSYN_s(:,k-1) + dt*F;
  F=((-((3.6)*(dendrite_K_n(k-1).^4).*(dendrite_v(k-1)-(-77))))+((-((12)*dendrite_Na_h(k-1).*(dendrite_Na_m(k-1).^3).*(dendrite_v(k-1)-(50))))+(((10))+((-((0.03)*(dendrite_v(k-1)-(-54.4))))+((-((((0.1).*dendrite_iMultiPoissonExp_Ge(:,max(1,round(dendrite_v(k-1)/(0.01))))).*(dendrite_v(k-1) - (0))) + (((0.1).*dendrite_iMultiPoissonExp_Gi(:,max(1,round(dendrite_v(k-1)/(0.01))))).*(dendrite_v(k-1) - (-85)))))+((((0.15).*sum((((soma_v(:,k-1)*ones(1,size(soma_v(:,k-1),1)))'-(dendrite_v(k-1)*ones(1,size(dendrite_v(k-1),1))))).*soma_dendrite_iCOM_compcon,2)))+(((((0)/((0.3)*(1))).*sum(((dendrite_v(k-1)*ones(1,size(dendrite_v(k-1),1)))'-(dendrite_v(k-1)*ones(1,size(dendrite_v(k-1),1)))).*dendrite_dendrite_iGAP_mask,2)))+0)))))))/(1);
  dendrite_v(k) = dendrite_v(k-1) + dt*F;
  F=(.01*(dendrite_v(k-1)+55)./(1-exp(-(dendrite_v(k-1)+55)/10))).*(1-dendrite_K_n(k-1))-(.125*exp(-(dendrite_v(k-1)+65)/80)).*dendrite_K_n(k-1);
  dendrite_K_n(k) = dendrite_K_n(k-1) + dt*F;
  F=(.1*(dendrite_v(k-1)+40)./(1-exp(-(dendrite_v(k-1)+40)/10))).*(1-dendrite_Na_m(k-1))-(4*exp(-(dendrite_v(k-1)+65)/18)).*dendrite_Na_m(k-1);
  dendrite_Na_m(k) = dendrite_Na_m(k-1) + dt*F;
  F=(.07*exp(-(dendrite_v(k-1)+65)/20)).*(1-dendrite_Na_h(k-1))-(1./(1+exp(-(dendrite_v(k-1)+35)/10))).*dendrite_Na_h(k-1);;
  dendrite_Na_h(k) = dendrite_Na_h(k-1) + dt*F;
  if any(k == enableLog)
    elapsedTime = toc(tstart);
    elapsedTimeMinutes = floor(elapsedTime/60);
    elapsedTimeSeconds = rem(elapsedTime,60);
    if elapsedTimeMinutes
        fprintf(fileID,'Processed %g of %g ms (elapsed time: %g m %.3f s)\n',T(k),T(end),elapsedTimeMinutes,elapsedTimeSeconds);
    else
        fprintf(fileID,'Processed %g of %g ms (elapsed time: %.3f s)\n',T(k),T(end),elapsedTimeSeconds);
    end
  end
end
Y=cat(1,soma_v,soma_K_n,soma_Na_m,soma_Na_h,soma_soma_iSYN_s,dendrite_v,dendrite_K_n,dendrite_Na_m,dendrite_Na_h)';
