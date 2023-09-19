function z_decay = ZDecay(z_decay,decay_rate,z)

z_decay = (z==1)+(z==0).*(decay_rate.*z_decay);