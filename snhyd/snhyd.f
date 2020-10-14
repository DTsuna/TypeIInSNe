      program snhyd
cexpl   one dimensional lagrangian hydrodynamic scheme.
c---  initial data is required.

      include 'inclm1.f'

      integer idev, ni, ipass, jj, kk
      common/nickel/ni
      real*8 msol, kh, eje, AU
      character*20 hyd, lightc
      character*128 filename 
      parameter ( msol = 1.989e33, kh = 8.3147515e7, AU=1.495978707e13 )
      real*8 dmass(mn), encm(mn), encmg(mn), tp(100)
      real*8 taum(mn), pm(mn), um(mn), arm(mn), gm(mn), g1m(mn)
     &     ,taup(mn), pp(mn), up(mn), arp(mn), gp(mn), g1p(mn)
      real*8 taul(mn), pl(mn), ul(mn), arl(mn), gl(mn), g1l(mn)
     &     ,taur(mn), pr(mn), ur(mn), arr(mn), gr(mn), g1r(mn)
      real*8 psl(mn), psr(mn), usl(mn), usr(mn)
      real*8 kap(mn), lum(mn), cv(mn)
      real*8 ps(mn), us(mn), pn
      real*8 tauo(mn)

      real*8 u_eos(mn)
      real*8 old_e(mn)
      real*8 old_eu(mn),integrate
      real*8 e_without
      real*8 boundr
      integer output_do
      real*8 when_out(99)

!      data when_out/1.d2,1.d6,2.d6,3.d6,4.d6
!     $     ,5.d6,6.d6,6.2d6,6.4d6,6.6d6
!     $     ,6.8d6,7.0d6,7.2d6,7.4d6,7.6d6
!     $     ,7.8d6,8.0d6,8.2d6,8.4d6,8.6d6
!     $     ,8.8d6,9.0d6,9.2d6,9.4d6,9.6d6
!     $     ,9.8d6,10.0d6,10.2d6,10.4d6,10.6d6
!     $     ,10.8d6,11.0d6,11.5d6,12.0d6,12.5d6
!     $     ,13.0d6,13.5d6,14.0d6,14.5d6,15.0d6
!     $     ,15.5d6,

      data when_out/1.d2,16.0d6,16.5d6,17.0d6,17.5d6
     $     ,18.0d6,18.5d6,19.0d6,19.5d6,20.0d6
     $     ,21.d6,22.d6,23.d6,24.d6,25.d6
     $     ,26.d6,27.d6,28.d6,29.d6,30.d6
     $     ,31.d6,32.d6,33.d6,34.d6,35.d6
     $     ,36.d6,37.d6,38.d6,39.d6,40.d6
     $     ,41.d6,42.d6,43.d6,44.d6,45.d6
     $     ,46.d6,47.d6,48.d6,49.d6,50.d6
     $     ,51.d6,52.d6,53.d6,54.d6,55.d6
     $     ,56.d6,57.d6,58.d6,59.d6,60.d6
     $     ,61.d6,62.d6,63.d6,64.d6,65.d6
     $     ,66.d6,67.d6,68.d6,69.d6,70.d6
     $     ,71.d6,72.d6,73.d6,74.d6,75.d6
     $     ,76.d6,77.d6,78.d6,79.d6,80.d6
     $     ,81.d6,82.d6,83.d6,84.d6,85.d6
     $     ,86.d6,87.d6,88.d6,89.d6,90.d6
     $     ,91.d6,92.d6,93.d6,94.d6,95.d6
     $     ,96.d6,97.d6,98.d6,99.d6,100.d6
     $     ,70.d6,80.d6,90.d6,100.d6,100.d7
     $     ,275.d4
     $     ,27.d6,28.d6,30.d6/


      logical finish

      common/opdept/tauo
      common /riem/ ps, us
      common /mass/encm, dmass
      common /avarg/ taum, pm, um, arm, gm, g1m, taup, pp,
     &              up, arp, gp, g1p
      common /lumi/ lum
      common /intp/ taul, pl, ul, arl, gl, g1l
     &            , taur, pr, ur, arr, gr, g1r
      common /massn/ am(14)
      data iarrv, finish/0, .false./

      real*8 e_charge_tot, injection_time, time_to_cc
!f90から作ったオブジェクトファイルが使えるかチェック
!      call sample


      output_do = 1

      pn = 0.d0
      am(1) = 1.d0
      am(2) = 4.d0
      do 5 k = 3, 14
         am(k) = 4.d0*k
 5       continue
      alpha = 0.d0
      open(17,file='snhydOutput/start.time',status='unknown')
      write(17,*)'just starting'
      close(17)
      open(18,file='snhyd/para1.d',status='old')
      read(18,*)
      read(18,*)istart,ihydm, jw, iout, idev
      read(18,*)
      read(18,*)cut, dtcfac, eje, nadd
      read(18,*)
      read(18,*)ntp,(tp(k),k=1,ntp)
      read(18,*)
      read(18,*)hyd
      read(18,*)lightc
      write(*,*)' iout = ',iout
      close(18)

        
      open(21,file='snhyd/eruptPara.d',status='old')
      read(21,*)
      read(21,*)time_to_cc, e_charge_tot, injection_time
      close(21)

      open(66,file='snhydOutput/passage@0.1AU.txt',form='formatted')
      write(66,*)' no. time radius mass density velocity pressure'
     $     ,' temperature'
c$$$      do k = 1, ntp
c$$$         tp(k) = tp(k)*8.64d4
c$$$      enddo
cexpl  construct the initial model
c      time = 0.d0
      call init(n, hyd, alpha, cut, istart, time, encmg, eje, nadd)
      boundr = (rad(3)+rad(4))/2.d0

      nna = n-nadd
      ipass = n
      write(*,*)' number of meshes ',n,' mass cut ',cut/1.989e33
      pn = 0

      call grav(n,encmg)

      l = max(1,1-istart)
      print *,e(3)
      call tote(n,nadd,e,dmass,rad,grv,u,te,tet)

      write(*,'(''total energy ='',1pe12.4,''erg, etherm =''
     $     ,e12.4,'' erg'')')te, tet

c$$$      if(idev.ne.0)call view(nna,idev,time,rad,tau,p,u,ye,lum,temp)

!      call eos(n,1,cv,kap)
      call eoshelm(n,cv,temp,e,tau,p,x,
     %        grv,rad,eu,g,g1,cs,u,mn,nelem,time)

      call tote(n,nadd,e,dmass,rad,grv,u,te,tet)

      write(*,'(''total energy ='',1pe12.4,''erg, etherm =''
     $     ,e12.4,'' erg'')')te, tet

      write(*,66)(j,encm(j)/msol,rad(j),1.d0/tau(j),p(j),u(j),e(j)
     &            ,temp(j),j=max(1,jw-10),max(10,min(jw+10,n)))
 66    format(' no.',4x,'mr',4x,'rad',8x,'rho',6x,'p',5x,'vel'
     &       ,8x,'e',8x,'temp',/,(i4,1p7e9.2))

      call state(n,dt,psl,psr,usl,usr)
!      do j= 2, n-1
!         gl(j)=g(j)
!         g1l(j)=g1(j)
!         taup(j)=tau(j)
!         psl(j)=p(j)
!         usl(j)=u(j)
!         gr(j)=g(j+1)
!         g1r(j)=g1(j+1)
!         psr(j)=p(j+1)
!         taum(j)=tau(j+1)
!         usr(j)=u(j+1)
!      enddo
!      j=n
!      gl(j)=g(j)
!      g1l(j)=g1(j)
!      taup(j)=tau(j)
!      psl(j)=p(j)
!      usl(j)=u(j)
!      gr(j)=g(j)
!      g1r(j)=g1(j)
!      psr(j)=p(j)
!      taum(j)=tau(j)
!      usr(j)=u(j)




      call riemnt( n,ihyd,gl,gr,g1l,g1r,psl,psr,taup,taum,usl,
     *     usr,pn)
      open (11,file='snhydOutput/hyd.d',
     $               status='unknown',form='formatted')
      WRITe(11,'(''total energy ='',1pe12.4,''erg, total mass =''
     $     ,e12.4,'' Msun'')')te, encm(n)/1.989e33
      close(11)
      open (12,file='snhydOutput/lightc.d',
     $               status='unknown',form='formatted')
!      call output(n, alpha, istart, time, dt) !先頭からcを消した
c 67    format(i5,1p3e12.4)
      dt = 0.d0
      kp = 1
      do 9 kpp = 1, ntp
         if(tp(kpp).gt.time)then
            kp = kpp
            go to 95
         end if
 9    continue
cexpl  start the hydrodynamical calculation
 95   write(*,*)'calculation starts here'
      ihyd = istart
c$$$      do 10 ihyd = istart, ihydm
      do while(time.le.tp(ntp))
      print *,time,ihyd,dt				!確認用




!      if(ihyd.eq.89496)then
!         open (11,file='snhydOutput/hyd.d',access='append',form='formatted')
!         call output(n, alpha, ihyd, time, dt)
!         close(11)
!      end if

      if(output_do.le.96)then
        if(time.gt.when_out(output_do))then
           write (filename, '("snhydOutput/result", i2.2, ".txt")')
     $         output_do
           open(91, file=filename,status='unknown',form='formatted')
           write(91,93)n,time,dt,ihyd,(j,rad(j),encm(j),dmass(j),
     $       1./tau(j), u(j), p(j), e(j), temp(j), lum(j)*1d-40, ye(j),
     $       j= 3, n)
 93     format(i5,' time', 1pe12.4,' sec',' dt',e12.4,' sec  istep ',i8
     &  ,/,' no.',5x,'rad',10x,'encm',13x,'dm',12x,'rho',14x,'v'
     &         ,14x,'p',14x,'e',14x,'t',/,(i5,1p10e15.7))
           close(91)
           output_do = output_do + 1
        end if
      end if
 

      call cournt( n, dtcfac, time, dtc )
      dt = min(tp(kp)-time,dtc)
      if(dt.lt.dtc)kp = kp+1
      if(dt.le.0.d0)then
         write(*,*)dtc,dt,time,kp
         stop' due to negative time step'
      end if

      if(dt.gt.500.d0)dt = 500.d0
!      if(dt.gt.1.d-8)dt = 1.d-8


      call state(n,dt,psl,psr,usl,usr)
!      do j= 2, n-1
!         gl(j)=g(j)
!         g1l(j)=g1(j)
!         taup(j)=tau(j)
!         psl(j)=p(j)
!         usl(j)=u(j)
!         gr(j)=g(j+1)
!         g1r(j)=g1(j+1)
!         psr(j)=p(j+1)
!         taum(j)=tau(j+1)
!         usr(j)=u(j+1)
!      enddo
!      j=n
!      gl(j)=g(j)
!      g1l(j)=g1(j)
!      taup(j)=tau(j)
!      psl(j)=p(j)
!      usl(j)=u(j)
!      gr(j)=g(j)
!      g1r(j)=g1(j)
!      psr(j)=p(j)
!      taum(j)=tau(j)
!      usr(j)=u(j)



      call riemnt( n,ihyd,gl,gr,g1l,g1r,psl,psr,taup,taum,usl,
     *   usr,pn)

      write(*,*)"before advanc"
      call tote(n,nadd,e,dmass,rad,grv,u,te,tet)
      write(*,*)"e_tot eu_tot",te,tet
!      write(*,*)"e(3)eu(3)",e(3),eu(3),temp(3)
!      write(*,*)"e(110)eu(110)",e(110),eu(110),temp(110)
!      write(*,*)"e(n)eu(n)",e(n),eu(n),temp(n)
      call advanc(n,alpha,nadd,dt,dmass,encmg,time,boundr,
     $                e_charge_tot,injection_time)
c      call grow(n, finish, dt, time, encmg)
      time = time + dt
      write(*,*)"timetocc=",time_to_cc

! opac.called here before debug
!      call opac(n, kap,iphoto)

c$$$      do 11 i = 1, n
c$$$         kap(i) = 0.4
c$$$ 11   continue
!手始めにここの状態方程式を置き換えてみる
!      call eos(n,1,cv,kap)

      do jj = 3,n
        u_eos(jj)= (us(jj - 1)+us(jj))/2.d0
      end do

      call tote(n,nadd,e,dmass,rad,grv,u,te,tet)
!      write(*,*)"e(3)eu(3)",e(3),eu(3),temp(3)
!      write(*,*)"e(110)eu(110)",e(110),eu(110),temp(110)
!      write(*,*)"e(n)eu(n)",e(n),eu(n),temp(n)


      call eoshelm(n,cv,temp,e,tau,p,x,grv,rad,eu,g,g1,cs,u,mn,
     $   nelem,time)
      call tote(n,nadd,e,dmass,rad,grv,u,te,tet)


      write(*,*)"e_tot eu_tot",te,tet
!      write(*,*)"e(3)eu(3)",e(3),eu(3),temp(3)
!      write(*,*)"e(110)eu(110)",e(110),eu(110),temp(110)
!      write(*,*)"e(n)eu(n)",e(n),eu(n),temp(n)
!      call eoshelm_e(n,cv,temp,e,tau,p,x,grv,rad,eu,g,g1,cs,u,mn,
!     $           nelem)


! opac called here for debug
      call opac(n, kap,iphoto)
      call radtra(n,ihyd,dt,time,cv,kap)



      call tote(n,nadd,e,dmass,rad,grv,u,te,tet)


!      write(*,*)"e(3)eu(3)",e(3),eu(3),temp(3)
!      write(*,*)"e(110)eu(110)",e(110),eu(110),temp(110)
!      write(*,*)"e(n)eu(n)",e(n),eu(n),temp(n)


!      if(ihyd.eq.1)pause
      if(ihyd.gt.0)then
!      if(ihyd/iout*iout.eq.ihyd)then
c$$$         jw = iphoto
         call tote(n,nadd,e,dmass,rad,grv,u,te,tet)
         write(*,'(''total energy ='',1pe12.4,''erg, etherm =''
     $        ,e12.4,'' erg'')')te, tet
         write(*,
     $        '(8h time = ,1pe12.4,4h sec,6h dt = ,e12.4,4h sec,
     $        6h ihyd ,i8)')
     $        time, dt, ihyd
         write(*,'(5h no.  ,8h  mr    ,9hradius   9hdensity  ,
     $        9hpressure ,9hvelocity ,9h     e   ,9h temp    ,
     $        9h    u   ,/,(i5,1p8e9.2))')
     $        (j,encm(j)/msol,rad(j),1.d0/tau(j),ps(j),us(j),e(j)
     $        ,temp(j),u(j),j=max(1,jw-10),max(10,min(jw+10,n)))
c$$$         if(idev.ne.0)call view(nna,idev,time,rad,tau,p,u,ye,lum,temp)
      endif
      kp1 = max(kp-1,1)
      if(time.eq.tp(kp1)) then
         open (11,file='snhydOutout/hyd.d',
     $           access='append',form='formatted')
!         call output(n, alpha, ihyd, time, dt)
         close(11)
      end if
!      if(u(n).gt.2.d9.and.iarrv.eq.0)then
      if(u(n).gt.1.d9.and.iarrv.eq.0)then
         open (11,file='snhydOutput/hyd.d',
     $        access='append',form='formatted')
!         call output(n, alpha, ihyd, time, dt)
         close(11)
         iarrv = 1
         print *,"shock breaks out at t=",time
      end if
!      if(rad(ipass).ge.0.1*AU.and.ipass.ge.3)then
!         write(66,'(i6,1p7e15.7)')ipass,time,rad(ipass),dmass(ipass),
!     $        1.0/tau(ipass),u(ipass),p(ipass),temp(ipass)
!         if(ipass.eq.3)then
!            close(66)
!            write(*,*)"end in ipass"
!            stop
!         endif
!        ipass=ipass-1
!      endif

c         writel = abs(olumn-time)/(0.5d0*(time+olumn))
c         writel = abs(olumn-lum(iphoto))/(0.5d0*(lum(iphoto)+olumn))
c$$$         writel = 1.d0
c$$$         if(writel.gt.1d-2) then
c$$$            ilum = iphoto
c$$$            if(ilum.gt.ni)then
c$$$               dtaui = (0.666666667d0-tauo(ilum))/(tauo(ilum+1)
c$$$     $              -tauo(ilum))
c$$$               write(12,'(1p3e15.7,i5,e15.7)')time/8.64d4,
c$$$     $              (log10(temp(ilum+1))-log10(temp(ilum)))
c$$$     $              *dtaui+log10(temp(ilum)),
c$$$     $              (log10(lum(ilum+1)+1.d0)-log10(lum(ilum)+1.d0))
c$$$     $              *dtaui+log10(lum(ilum)+1.d0), iphoto,rad(iphoto)
c$$$               olumn = lum(iphoto)
c$$$            else
c$$$               write(12,'(1p3e15.7,i5,e15.7)')time/8.64d4,
c$$$     $              log10(temp(ni)),log10(lum(ni)),iphoto,rad(iphoto) 
c$$$               write(6,'(1p3e15.7,i5,e15.7)')time/8.64d4,
c$$$     $              log10(temp(ni)),log10(lum(ni)),iphoto,rad(iphoto) 
c$$$               olumn = time
c$$$           endif
c$$$         end if
         if(kp1.eq.ntp)then
            finish = .true.
            call grow(n, finish, dt, time, encmg)
            go to 99
         end if
         if(iarrv.eq.1)then
            jn=n
            do j = 3, n
!               if(tau(j)/tau(j-1).lt.1d-7)then
               if(u(j).gt.1.d9.or.1.d0/tau(j).lt.1e-17)then
!                  jn=j-1
                  jn=j-2
                  print *,"jn=",jn
                  exit
               end if
            enddo
            if(jn.lt.n)then
!               jw = jw+(jn-n)
               n = jn
               print *,"n changes to",n," rho(j)=",1.d0/tau(n+1),
     $              " rho(j-1)=",1.d0/tau(n)
            end if
         endif
         ihyd = ihyd+1
      enddo
c$$$ 10   continue 
      finish = .true.
      call grow(n, finish, dt, time, encmg)
      call output(n, alpha, ihyd, time, dt)
 99   close(12)
      close(11)
      write(*,*)"at 99"
      open(19,file='snhydOutput/finish.time',status='unknown')
      write(19,*)'just finished'
      close(19)
      stop' normal end.'
      end
