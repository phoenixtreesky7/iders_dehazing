# iders_dehazing

This is a Matlab re-implementation of the paper.

IDeRS: Iterative Dehazing Method for Single Remote Sensing Image

Long Xu, Dong Zhao, Yihua Yan, Sam Kwong, Jie Chen, Lingyu Duan

This work has been accepted by Information Sciences, 2019. If you have any interesting problems on our work, we sincerely welcome your valuable advises, and you can email us by:

dzhao@nao.cas.cn | lxu@nao.cas.cn | zhaodong_biti@163.com


# Abstract

Remote sensing images (RSIs) taken in hazy conditions, such as haze, fog, thin could, snow, silt, dust, offgas, etc., suffer from sever color and contrast degradations. In the last decade, lots of dehazing algorithms were proposed mainly for nature images. Although natural image dehazing (NID) was also applicable to remote sensing image dehazing (RSID), in-depth exploration on physical model of RSID was not clearly addressed yet. RSID using conventional dehazing method exits three technique challenges. The first two challenges are the atmospheric light and transmission map estimations. For the former, we employ the haze-line prior method, since it is independent to haze-opaque pixels which are commonly used in NID but nonexist in RSIs. For the latter, we investigate the physical models of NID and RSID, and find that the transmission map of NID and RSID are mathematically similar, meaning that they can share the same estimating model. Thus, we employ the dark channel prior (DCP) method to estimate the raw transmission map. However, DCP has only single patch size, leading to poor effectiveness for VHR RSID. To solve this challenge, we propose an Iterative Dehazing method for Remote Sensing image (IDeRS). In IDeRS, we raise a fusion model for combining patch-wise and pixel-wise dehazing operators iteratively, so as to remove haze at all scales. Another advantages of IDeRS is that it can overcome halos and over-saturation simultaneously. Extensive experimental results tested on publicly available databases demonstrate that, the proposed IDeRS outperforms most state-of-the-arts in single RSID.

# Model of the iders Dehazing

 ![model of TMR](https://github.com/phoenixtreesky7/iders_dehazing/raw/master/figures/model_tmr2.png)

 ![model of IDeRS](https://github.com/phoenixtreesky7/iders_dehazing/raw/master/figures/iteration_flow.png)

 ![hazy image](https://github.com/phoenixtreesky7/iders_dehazing/raw/master/figures/32.png)

 ![iders dehazed image](https://github.com/phoenixtreesky7/iders_dehazing/raw/master/figures/IDeRS_32_S3_I0.png)


# Implementation 

Add all file paths into MATLAB.

Then, run the code iders_demo.m

[NOTE] If your PC does not have GPU, you should using DCP method to estimate atmospheric light, i.e. set method.A = 0.
