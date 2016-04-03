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
/*30*/ test( "4:oe,pg,Np,zP,ho,pe,OV,S0,oM,wO,pM,Ah,Vq,9d,6U,3I,C9,AR,1L,rg,69,as,Nx", "12,1989" );
/*31*/ test( "2:n0,V0,zL,i0,4z,Nz,xz,z0,z1,0f,P0,zw,80,zC,zB,Az,0P,50,k0,rz,0D,jz,qz,E0", "2,2928" );
/*32*/ test( "2:tz,0F,0y,zo,0K,01,qz,zU,gz,Xz,zc,0m,zD,Q0,Yz,zb,0a,zp,zW,z7,0o,h0,1z,0p", "2,3660" );
/*33*/ test( "5:8r,NI,gL,3z,EK,hy,L9,g2,Kh,Gw,Dg,ZB,Sg,LY,ig,sS,I8,U0,DI,cq,Bu,qJ,C4,jP", "143,1520" );
/*34*/ test( "2:7s,z7,so,zw,X2,59,r1,0Q,70,q2,C6,J6,wz,at,2w,Vq,f9,st,sI,rf,wG,zg,f3,L2,4j", "4,2340" );
/*35*/ test( "2:kw,Gz,zp,se,8e,2S,C7,1A,B9,5v,AM,sN,zH,m8,Cx,rG,4w,q2,W0,ta,AC,G5,y0,Vq,3i", "4,2080" );
/*36*/ test( "3:Lr,pX,y7,2Y,qI,6w,t5,R6,e8,57,5f,R1,Up,9q,33,1Z,05,Eu,6S,AW,au,7S,zd,CA,R7", "7,2120" );
