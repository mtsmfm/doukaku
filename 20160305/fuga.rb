require 'bundler'
Bundler.require

def to_i(char)
  case char
  when '0'..'9'
    char.to_i
  when 'A'..'Z'
    char.ord - ?A.ord + 10
  when 'a'..'z'
    char.ord - ?a.ord + 36
  else
    binding.pry
    raise
  end
end

def count(ary)
  (x1, x2), (y1, y2) = ary
  (x1..x2).count * (y1..y2).count
end

def solve(input)
  n, blacks = input.scan(/(\d+):(.*)/).first
  n = n.to_i
  blacks = blacks.split(?,).map {|cs| cs.chars.map {|c| to_i(c) } }
  results = (0...62).to_a.repeated_combination(2).to_a.product((0...62).to_a.repeated_combination(2).to_a).select {|(x1, x2), (y1, y2)|
    blacks.count {|(x, y)| (x1..x2).cover?(x) && (y1..y2).cover?(y) } == n
  }.sort_by {|ary|
    count(ary)
  }
  min = count(results.first)
  max = count(results.last)

  "#{min},#{max}"

rescue
  '-'
end

def test(input, expect)
  actual = solve(input)

  if actual == expect
    puts "OK: #{input}"
  else
    raise "NG: #{input} : expect #{expect} but got #{actual}"
  end
end

DATA.each_line do |line|
  puts line
  eval line.match(%r{.*(test.*)}).captures.first
end

__END__
/*40*/ test( "7:6Q,av,UZ,0c,IV,fo,Vv,mg,no,qM,06,zy,jW,R0,Qo,sK,wQ,1b,De,Iy,zI,cx,rn,ot,cN,45", "250,2303" );
/*41*/ test( "4:0A,15,5k,Bi,mz,0f,vr,EZ,4z,vj,6p,vP,8X,16,x7,S3,2z,zJ,wI,wY,Wv,ky,9K,8u,Eo,4s,y0", "48,2700" );
/*42*/ test( "8:zN,2J,ta,HL,Dg,up,Qn,W8,8K,k4,Is,uL,dT,tA,PN,UQ,DB,gA,OO,lv,4h,Rv,D6,23,Tg,4S,Zb", "418,1763" );
/*43*/ test( "5:px,sp,cr,dB,fz,65,gq,zb,sN,42,o0,y3,iE,pv,sn,Al,RE,48,l0,7X,DE,xL,wC,qQ,w5,C3,P3,i1", "102,2397" );
/*44*/ test( "9:Ic,Dk,Ef,6R,GK,NZ,76,L0,oQ,9f,S3,oL,lX,7v,8d,pX,dZ,z7,zx,fR,pe,w7,aj,U9,lO,kv,wL,s0", "396,2088" );
/*45*/ test( "10:JJ,LR,Xe,kg,LU,lI,3w,ZV,Td,Mu,tA,g8,VC,I7,N8,zN,kY,Ux,3t,mg,4m,FO,Ug,vQ,qY,jl,Ne,Zq,GN", "416,1794" );
/*46*/ test( "11:lQ,EN,vO,tn,qO,F3,9k,K2,UC,P0,XY,DB,QO,ps,hy,fl,Dt,ex,Vc,vF,Pf,Vk,uo,Xc,Sh,KE,9g,3H,l6", "658,1995" );
