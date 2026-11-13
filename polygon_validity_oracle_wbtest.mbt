// Independent mathematical fixtures; angles below are radians.
// Oracle generator seed: 202611131107 (NumPy default_rng / PCG64).
// These are the original 200 triangle fixtures from the full oracle stream;
// the same stream generated cap/disc/polygon fixtures before these draws.
// Independently generate three planar points (u,v) uniformly in [-20,20]^2,
// then normalize (1,u,v). Every vertex has x>0, an explicit open-hemisphere
// witness. Gnomonic projection about +x maps minor great-circle arcs to
// planar segments, so each noncollinear triple bounds a valid convex triangle.
// Noncollinearity and positive x were checked outside this implementation.
// Expect construction to succeed and every supplied vertex to be contained.
// Expectations follow this construction, not SphericalPolygon output.
// Literal coordinates freeze the cases independently of future RNG changes.

///|
test "independent open hemisphere triangle 000" {
  let vertices = [
    LonLat::new(4.797238428041377, 0.9705330852152042),
    LonLat::new(1.5143868073910447, -0.446772884313922),
    LonLat::new(1.1438382010790114, -1.4202705666889128),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 001" {
  let vertices = [
    LonLat::new(4.79330633020149, -0.6487649806748211),
    LonLat::new(4.806178917380291, 0.3661152718856459),
    LonLat::new(4.814400036945297, 0.9979113431344303),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 002" {
  let vertices = [
    LonLat::new(1.5206815608988833, -0.1149266432518315),
    LonLat::new(1.0741049981285362, 1.271884323431429),
    LonLat::new(4.7753663664817525, -0.2297060579346422),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 003" {
  let vertices = [
    LonLat::new(4.768643007402696, 0.5596172731699819),
    LonLat::new(4.777977540229506, 0.5672358022990345),
    LonLat::new(0.9948369871200543, -1.4578020429044558),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 004" {
  let vertices = [
    LonLat::new(1.148029912693811, -1.3814532121978373),
    LonLat::new(1.4221612544109723, -0.17856846927684214),
    LonLat::new(1.4417989095027548, -0.6423777530991299),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 005" {
  let vertices = [
    LonLat::new(4.78431974261797, -0.2625386779791603),
    LonLat::new(0.9495536791867674, -1.4533832918811789),
    LonLat::new(1.4854363452627326, -0.8745447028460664),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 006" {
  let vertices = [
    LonLat::new(1.5207607507800402, 0.5486631939986295),
    LonLat::new(4.9125484947290134, -0.41218843813943645),
    LonLat::new(1.516562332937816, 0.4131236479267765),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 007" {
  let vertices = [
    LonLat::new(4.766003985995107, -0.4856161652132716),
    LonLat::new(1.444011746230206, 1.0481029764630942),
    LonLat::new(1.282658651483792, -1.3278668478822646),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 008" {
  let vertices = [
    LonLat::new(4.766656518106582, 0.49142321274016826),
    LonLat::new(4.86289586902385, -0.4199409764055156),
    LonLat::new(1.477739089352467, 0.7316916656253288),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 009" {
  let vertices = [
    LonLat::new(4.788287318081714, 0.8070774754219205),
    LonLat::new(4.798920045011305, -0.8097730874498517),
    LonLat::new(1.5118587169654867, 0.3887322425167533),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 010" {
  let vertices = [
    LonLat::new(4.764204905093813, -0.38167406598000975),
    LonLat::new(4.884659468802618, 0.5078180144090928),
    LonLat::new(1.4707346997247022, 0.70313831967505),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 011" {
  let vertices = [
    LonLat::new(4.780781876498625, -0.9261328528330824),
    LonLat::new(4.784765802231567, -0.3393297341297295),
    LonLat::new(1.3750322366583108, -0.3728454874470655),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 012" {
  let vertices = [
    LonLat::new(1.454594950923858, -0.10287428918199552),
    LonLat::new(4.803052290826062, -0.7153734814853339),
    LonLat::new(4.967912413474023, 1.2513855579595061),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 013" {
  let vertices = [
    LonLat::new(4.792399597115931, -0.7884679687688874),
    LonLat::new(4.769003217379941, 0.1592716945351926),
    LonLat::new(4.921901425832075, 1.3297894493641786),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 014" {
  let vertices = [
    LonLat::new(1.4705716964806108, 1.0897804742276207),
    LonLat::new(1.43053716694676, -1.2034446330158504),
    LonLat::new(4.767629720104499, 0.5996425040226241),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 015" {
  let vertices = [
    LonLat::new(4.807881471259014, -1.0075504424414619),
    LonLat::new(1.4654326667324873, 0.9489131226883053),
    LonLat::new(4.803806059673219, -0.7997366794429202),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 016" {
  let vertices = [
    LonLat::new(1.4992971878202095, 0.39977234276163526),
    LonLat::new(1.4145014860143577, 1.0454928833062427),
    LonLat::new(1.2480473138017303, -0.8840551122597246),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 017" {
  let vertices = [
    LonLat::new(4.766977161422723, 0.28807104778198883),
    LonLat::new(4.767316522798842, -0.588128608990982),
    LonLat::new(4.796051381733279, -0.37298388297672036),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 018" {
  let vertices = [
    LonLat::new(5.654281218438402, -1.4556534895077975),
    LonLat::new(5.151625975666374, -1.445730196831557),
    LonLat::new(0.5134118976614777, -1.4184369958252583),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 019" {
  let vertices = [
    LonLat::new(1.5055465212213777, 0.7019117661609188),
    LonLat::new(4.774131610902907, 0.1100279580465095),
    LonLat::new(4.76583261122998, 0.25845680747740907),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 020" {
  let vertices = [
    LonLat::new(1.3164497277334448, -1.2316143056634927),
    LonLat::new(4.813000153730281, -0.5728977852765971),
    LonLat::new(4.984888145806561, -1.2862861965523005),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 021" {
  let vertices = [
    LonLat::new(0.9874768118037139, -1.4040763992526901),
    LonLat::new(4.796131693013163, 0.18329538266773554),
    LonLat::new(1.4838749772281303, -0.8419996775688557),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 022" {
  let vertices = [
    LonLat::new(4.846032195014184, -1.2082864868477623),
    LonLat::new(1.5128006513011933, -0.41946759388882415),
    LonLat::new(1.4973672799508881, -0.3307093390592143),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 023" {
  let vertices = [
    LonLat::new(4.880595636332651, -0.5008132070839044),
    LonLat::new(0.5559049292390187, 1.5000438493183537),
    LonLat::new(4.825997855676533, 1.0137501104486573),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 024" {
  let vertices = [
    LonLat::new(1.51995783899979, -0.7292354503845794),
    LonLat::new(1.4870514703298818, 0.7942093781366597),
    LonLat::new(4.763085368694515, -0.47032376026536693),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 025" {
  let vertices = [
    LonLat::new(1.4979262154516597, -0.8886581761005974),
    LonLat::new(4.804248567094658, -0.20365654691979407),
    LonLat::new(4.763065476498901, 0.42283040480024375),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 026" {
  let vertices = [
    LonLat::new(4.762855432210116, 0.4561305747938717),
    LonLat::new(4.7721223844699425, 0.5887667034866726),
    LonLat::new(1.5070971306713956, 0.730147239672814),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 027" {
  let vertices = [
    LonLat::new(4.788379558830922, -0.6886901882193558),
    LonLat::new(4.774235040304667, 0.6845975653058459),
    LonLat::new(4.777117495199152, 0.24979647772872446),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 028" {
  let vertices = [
    LonLat::new(1.4790271020763806, 0.9681300561340859),
    LonLat::new(1.4266318444372865, 0.4611275322345369),
    LonLat::new(4.867157720976653, 1.2397075997207783),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 029" {
  let vertices = [
    LonLat::new(5.8341520014261565, -1.1944233779148308),
    LonLat::new(1.5105435132929155, -0.03933125797432645),
    LonLat::new(6.203718557486524, 1.4887071096966364),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 030" {
  let vertices = [
    LonLat::new(4.818628457462656, -0.6364615694417798),
    LonLat::new(4.775942381958985, 0.8273396244908121),
    LonLat::new(1.5157704479104077, -0.6515387526750702),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 031" {
  let vertices = [
    LonLat::new(4.771161066058533, 0.2763908253068631),
    LonLat::new(4.871985114632626, -1.0595279410664065),
    LonLat::new(1.5078309785947381, 0.8790377245727238),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 032" {
  let vertices = [
    LonLat::new(4.899372088829434, -1.2795154333886931),
    LonLat::new(4.849041916629119, 1.0977357725730268),
    LonLat::new(4.877841760056287, 1.1920092575613879),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 033" {
  let vertices = [
    LonLat::new(1.502695503078309, 0.8049878973579737),
    LonLat::new(4.769897987686121, -0.2178042209933235),
    LonLat::new(4.773710218775768, 0.7727016260208279),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 034" {
  let vertices = [
    LonLat::new(5.562429570909624, -1.444465120312487),
    LonLat::new(1.447520867609006, -0.0794853457474695),
    LonLat::new(1.5129142201544186, -0.4132971641361411),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 035" {
  let vertices = [
    LonLat::new(1.5139763015872878, 0.6263503041827106),
    LonLat::new(4.813144480817868, -0.7335898163573276),
    LonLat::new(4.836334934914256, -0.20915334017312817),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 036" {
  let vertices = [
    LonLat::new(1.4787030286423983, -0.029900129611103013),
    LonLat::new(1.43756696962477, 1.1720034836073532),
    LonLat::new(1.5134551189136782, -0.32157346007343995),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 037" {
  let vertices = [
    LonLat::new(1.4973293403037906, -0.8091490348569228),
    LonLat::new(1.4437007449103587, 0.1276989191228423),
    LonLat::new(0.6867835286959151, -1.2728707419007144),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 038" {
  let vertices = [
    LonLat::new(4.7697203468233305, 0.44877415823421946),
    LonLat::new(0.49760912389401324, -1.3407978355656398),
    LonLat::new(4.773235132067654, 0.4651036392465694),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 039" {
  let vertices = [
    LonLat::new(5.627895166015932, 1.5054839719992787),
    LonLat::new(4.7730706580801865, 0.47992526918249473),
    LonLat::new(4.766498596114301, -0.2482380631347236),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 040" {
  let vertices = [
    LonLat::new(1.51582263318296, 0.7203943329651818),
    LonLat::new(4.772434737511034, 0.5105902077996434),
    LonLat::new(4.770955278542537, -0.12869296376766398),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 041" {
  let vertices = [
    LonLat::new(1.3792077467348003, 0.8253059224367993),
    LonLat::new(4.781510631657063, -0.36821733963938313),
    LonLat::new(4.856441190383297, 0.9827421490657506),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 042" {
  let vertices = [
    LonLat::new(4.885674874302825, -0.18078476300593224),
    LonLat::new(4.909177337224585, -0.7825475133126082),
    LonLat::new(1.4543281475590106, -0.6484828376966758),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 043" {
  let vertices = [
    LonLat::new(4.77465845203843, -0.46066848270598276),
    LonLat::new(1.1588842750073587, -1.3509912092011442),
    LonLat::new(1.5045060945819144, 0.34634870852252597),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 044" {
  let vertices = [
    LonLat::new(4.784520249629009, -0.10797954016771731),
    LonLat::new(1.5164971352257897, -0.009937831624198468),
    LonLat::new(1.496813301740121, 0.3276186352303009),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 045" {
  let vertices = [
    LonLat::new(1.4940542205208938, 0.7340847376546339),
    LonLat::new(1.4653433645706135, -1.0835068752587544),
    LonLat::new(1.475631150128158, 1.0229772821377074),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 046" {
  let vertices = [
    LonLat::new(1.4440144131946513, -1.1936333245458806),
    LonLat::new(1.479322047968868, -1.0592927566250807),
    LonLat::new(4.8424772085383205, 0.9943133522636599),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 047" {
  let vertices = [
    LonLat::new(1.297952935262396, 1.3313284387178819),
    LonLat::new(1.5145976585024896, 0.03824554673401475),
    LonLat::new(4.8648123812047235, -1.2224297736539604),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 048" {
  let vertices = [
    LonLat::new(1.1431649872894245, 1.3463958194025114),
    LonLat::new(0.8390327232502331, 1.351483821252553),
    LonLat::new(0.8727355876087258, 0.7571691149410174),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 049" {
  let vertices = [
    LonLat::new(1.40145483959382, 1.2373264848186802),
    LonLat::new(1.5205899094825117, 0.7196336067571288),
    LonLat::new(5.023313999040847, 1.2784266300326463),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 050" {
  let vertices = [
    LonLat::new(4.7870888444104995, 0.031870275700257515),
    LonLat::new(4.807254751291133, 0.5953944983519237),
    LonLat::new(1.4730091845170055, 0.997020106915894),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 051" {
  let vertices = [
    LonLat::new(4.787585350297711, 0.9079659068321144),
    LonLat::new(4.861742570842791, -0.9321475331195315),
    LonLat::new(4.974108084970539, -0.894583518450506),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 052" {
  let vertices = [
    LonLat::new(1.5055007282974497, -0.5087635188145869),
    LonLat::new(1.5171414698224168, -0.356900409941078),
    LonLat::new(1.5173097041721284, -0.03969944499998634),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 053" {
  let vertices = [
    LonLat::new(1.3498432398388098, 1.2507920438820395),
    LonLat::new(1.4907293194678444, -0.9488152664722227),
    LonLat::new(1.5157101426954775, 0.6095322893256584),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 054" {
  let vertices = [
    LonLat::new(4.878940600114015, -1.0055933525263139),
    LonLat::new(1.4868923223338526, -1.025508991032177),
    LonLat::new(1.5171788229224281, 0.22680936941664342),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 055" {
  let vertices = [
    LonLat::new(5.509066185525656, -0.153510822100776),
    LonLat::new(4.8666202902125715, -1.1293499099324336),
    LonLat::new(4.8036628009364515, 0.36898515950723626),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 056" {
  let vertices = [
    LonLat::new(4.8370311500876095, -0.08036689841466657),
    LonLat::new(4.8191172969762235, -0.04038637358865343),
    LonLat::new(4.799151170018636, -0.4068220198160518),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 057" {
  let vertices = [
    LonLat::new(1.511171768549536, 0.5833551687992489),
    LonLat::new(0.8039757811350975, 1.130401449963528),
    LonLat::new(5.679027197950102, -1.416891677615995),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 058" {
  let vertices = [
    LonLat::new(1.205948479397368, 1.2689588326952264),
    LonLat::new(4.7641904188959705, 0.23395296041113695),
    LonLat::new(4.875234679299903, 1.2616620413219686),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 059" {
  let vertices = [
    LonLat::new(4.88212401252314, -0.6809572104654827),
    LonLat::new(5.082198058583666, 0.10417722635384227),
    LonLat::new(1.0644308884842333, 1.170098880204629),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 060" {
  let vertices = [
    LonLat::new(1.4669881835243086, -0.645488977636965),
    LonLat::new(4.962050289791544, 0.39489751282950186),
    LonLat::new(5.100573014703537, -1.4025201332208819),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 061" {
  let vertices = [
    LonLat::new(1.479233607499392, 0.40783541266894585),
    LonLat::new(1.513125078068409, 0.2902801633226915),
    LonLat::new(4.876632333993283, -1.2658927618640556),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 062" {
  let vertices = [
    LonLat::new(4.985750144228142, 1.3695310262778173),
    LonLat::new(1.4222704407473545, 0.6083918020137737),
    LonLat::new(4.765749844111795, 0.2533752106860512),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 063" {
  let vertices = [
    LonLat::new(0.9619446394056747, -1.133972726540576),
    LonLat::new(4.768698948489444, -0.6481631424847497),
    LonLat::new(0.2872583336781121, -1.5008365486312574),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 064" {
  let vertices = [
    LonLat::new(1.3867104992365606, 0.23861151170889058),
    LonLat::new(5.5643410770267305, -0.4635942213078881),
    LonLat::new(4.775115519326582, 0.7946593212525052),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 065" {
  let vertices = [
    LonLat::new(1.3542425568177912, 1.0043595177754407),
    LonLat::new(4.905452324244727, -1.0835597040938483),
    LonLat::new(4.768644431904766, 0.7713634435008715),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 066" {
  let vertices = [
    LonLat::new(1.4352098766083123, -0.8487711358296801),
    LonLat::new(4.784230488513179, -0.6572010513434685),
    LonLat::new(4.902118578072623, 1.1364435566493492),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 067" {
  let vertices = [
    LonLat::new(1.5182740619103823, 0.40745522079916047),
    LonLat::new(0.36646038892566785, -1.4611317808065445),
    LonLat::new(1.5109073323685307, -0.7290938425649466),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 068" {
  let vertices = [
    LonLat::new(5.024585510968939, 1.3889670457004708),
    LonLat::new(1.3994664239401995, -1.0617926318774842),
    LonLat::new(4.871787807907822, 0.12487289701860711),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 069" {
  let vertices = [
    LonLat::new(1.4855700704331845, 0.33276194735637776),
    LonLat::new(1.4795155982690487, 0.7578190625015485),
    LonLat::new(0.2645829080692816, 1.405499991017622),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 070" {
  let vertices = [
    LonLat::new(1.4804850442423723, -0.15803839639457487),
    LonLat::new(1.4370961072087143, -1.1951784691165193),
    LonLat::new(1.5137794557605149, -0.0912924692985944),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 071" {
  let vertices = [
    LonLat::new(1.2822024725642536, 1.3869744484370712),
    LonLat::new(1.4546912554548668, 1.1456867048432529),
    LonLat::new(1.1940983329285415, -1.4139842231866615),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 072" {
  let vertices = [
    LonLat::new(0.7618093637149815, 1.3433069103892732),
    LonLat::new(1.3760603045211393, -0.7359112597571278),
    LonLat::new(1.3918015068488618, 0.45300780260909346),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 073" {
  let vertices = [
    LonLat::new(1.497819318086816, -0.23676568700901182),
    LonLat::new(1.4228363004822842, 1.0229895617083906),
    LonLat::new(1.5165826097913881, 0.5740463065797633),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 074" {
  let vertices = [
    LonLat::new(1.467641110778296, -0.8721070201461798),
    LonLat::new(1.4056124968341972, 0.7988816634368304),
    LonLat::new(1.4663013525950614, -0.9609499698543994),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 075" {
  let vertices = [
    LonLat::new(1.5183010605583103, -0.6670251179697392),
    LonLat::new(4.766524886763051, -0.12580088091108274),
    LonLat::new(1.458317011011059, 1.0508915559156546),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 076" {
  let vertices = [
    LonLat::new(1.5199088155448968, 0.526693948231312),
    LonLat::new(1.4933555038384625, 0.9007855098078498),
    LonLat::new(4.771645658265678, 0.6194983619984258),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 077" {
  let vertices = [
    LonLat::new(0.7973480930931489, 1.3066547536015356),
    LonLat::new(4.76525255748565, -0.3202167162992841),
    LonLat::new(0.23669624732063926, -1.5037293852583755),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 078" {
  let vertices = [
    LonLat::new(4.772596169789278, 0.3272912802412213),
    LonLat::new(1.4921642802700543, -0.9630131614324663),
    LonLat::new(1.408672858660347, -0.7628734067374451),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 079" {
  let vertices = [
    LonLat::new(1.3940581137561763, 1.2123576144566277),
    LonLat::new(4.8979790768205556, 0.686355347111205),
    LonLat::new(0.35423494777315134, 1.4237392684370218),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 080" {
  let vertices = [
    LonLat::new(5.659839916101679, -1.5030039791597425),
    LonLat::new(1.3852822790098545, -1.1808983548972543),
    LonLat::new(4.806001318790598, 0.9681120478118738),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 081" {
  let vertices = [
    LonLat::new(1.4847771474139377, -0.16426411977456598),
    LonLat::new(4.766513033402119, 0.3406175060696133),
    LonLat::new(4.791066785920923, -0.9636266818512829),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 082" {
  let vertices = [
    LonLat::new(1.494480491048302, 0.9143292427471065),
    LonLat::new(1.419888489894123, -0.9766923131059331),
    LonLat::new(4.83674418650663, -0.7842797173548146),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 083" {
  let vertices = [
    LonLat::new(1.4977072935364544, 0.15454134786958743),
    LonLat::new(5.985432481787184, 1.4909879843634262),
    LonLat::new(1.451310351815446, 1.15763190290776),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 084" {
  let vertices = [
    LonLat::new(4.765382371579749, 0.7016192101533065),
    LonLat::new(5.338766265975313, -1.4140755745990892),
    LonLat::new(1.50148658916289, 0.6545422521710668),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 085" {
  let vertices = [
    LonLat::new(1.2173682105604196, 1.3470988411702687),
    LonLat::new(1.4479092775937652, -0.8397427111818917),
    LonLat::new(4.781001235679123, 0.06996934869209888),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 086" {
  let vertices = [
    LonLat::new(4.81054563451345, -0.3347133236622886),
    LonLat::new(4.841603715268827, -1.1825384694007128),
    LonLat::new(0.9827860700324075, -1.4207759121351298),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 087" {
  let vertices = [
    LonLat::new(4.823243749459792, 0.5700687474147625),
    LonLat::new(4.790547977721692, 0.5386190054076379),
    LonLat::new(4.830345190120855, -0.8808485078844259),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 088" {
  let vertices = [
    LonLat::new(4.8760387058724675, 1.1304112021360018),
    LonLat::new(4.777035981441429, -0.3261192169978301),
    LonLat::new(1.107737752175913, 1.296768043940781),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 089" {
  let vertices = [
    LonLat::new(4.775673599012338, 0.6924205918328417),
    LonLat::new(1.506963761688346, 0.8640236975222472),
    LonLat::new(1.385536028446545, -1.2443429740756133),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 090" {
  let vertices = [
    LonLat::new(1.4366144031627281, 1.2035241908000187),
    LonLat::new(1.5166942933194256, -0.1437124074111828),
    LonLat::new(1.5130001555382284, 0.24834214641292748),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 091" {
  let vertices = [
    LonLat::new(4.763233243659305, 0.48855149523412894),
    LonLat::new(5.268755505001277, 0.027865259048639898),
    LonLat::new(1.347792919044304, -0.06725955987377438),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 092" {
  let vertices = [
    LonLat::new(4.814001986413314, -1.0959388296584205),
    LonLat::new(1.0789253844429814, -1.4049793937195123),
    LonLat::new(5.010337070788559, 1.3162782839222282),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 093" {
  let vertices = [
    LonLat::new(1.0316007709470454, -1.4215902441074064),
    LonLat::new(1.4104896158796012, -0.1557236522007428),
    LonLat::new(4.8129814939061895, -0.36720685872603126),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 094" {
  let vertices = [
    LonLat::new(5.221185287688522, 1.4169902844964102),
    LonLat::new(5.183392756978779, -1.3592676601824318),
    LonLat::new(4.819469696841469, 1.027686510188758),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 095" {
  let vertices = [
    LonLat::new(1.5109695702851906, -0.47026900968892177),
    LonLat::new(4.783922599284311, 0.6271115078288442),
    LonLat::new(5.009708886646368, 0.6571356393279392),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 096" {
  let vertices = [
    LonLat::new(0.028594526280846744, 1.3437410800973475),
    LonLat::new(4.826463605653437, 0.10544867058482583),
    LonLat::new(4.9520561413823385, 1.2147004432761772),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 097" {
  let vertices = [
    LonLat::new(1.317591311126148, 0.24238592525044358),
    LonLat::new(4.804797331037757, 0.6769035653849356),
    LonLat::new(4.791784994988304, -0.5343911128651918),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 098" {
  let vertices = [
    LonLat::new(5.364993034677495, 1.4697319535240867),
    LonLat::new(1.5083497610561918, 0.19979373647132082),
    LonLat::new(4.799918837974443, 0.34720283642505106),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 099" {
  let vertices = [
    LonLat::new(1.479578970515939, -0.8498478299030908),
    LonLat::new(1.463268728660667, -0.6143785792914852),
    LonLat::new(4.840235652640606, 0.5595594330642881),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 100" {
  let vertices = [
    LonLat::new(6.066248468662278, 1.5090362716845114),
    LonLat::new(4.762491424042161, -0.5941130705609649),
    LonLat::new(4.770657829874111, 0.6982014043912591),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 101" {
  let vertices = [
    LonLat::new(4.783064683759555, -0.4081208817365186),
    LonLat::new(5.364001963778738, 1.3602299761046441),
    LonLat::new(4.8505901732132175, 0.8590211171120534),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 102" {
  let vertices = [
    LonLat::new(1.491259036120351, 0.7515773368805797),
    LonLat::new(1.5019572304191149, -0.06739912881799093),
    LonLat::new(1.5071412132449395, 0.2625484407474605),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 103" {
  let vertices = [
    LonLat::new(1.5154465939060604, 0.6729188548639501),
    LonLat::new(4.771734731692765, 0.501151862336572),
    LonLat::new(4.764691437112632, 0.4242694482795849),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 104" {
  let vertices = [
    LonLat::new(4.874042278165222, 1.0994467108781465),
    LonLat::new(4.868360727905979, -1.2270087070535547),
    LonLat::new(4.791381525975117, 0.0024984496751540197),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 105" {
  let vertices = [
    LonLat::new(1.5180805103248793, -0.6936460438643761),
    LonLat::new(5.060990928763057, 0.17932129118010603),
    LonLat::new(4.806012425412649, -0.6591011853898324),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 106" {
  let vertices = [
    LonLat::new(1.4995648864153266, -0.6445950296510697),
    LonLat::new(4.763272907393483, 0.6474428854700026),
    LonLat::new(4.772782494496543, -0.5277022802102403),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 107" {
  let vertices = [
    LonLat::new(1.4913413498830188, 0.8311673161813875),
    LonLat::new(1.5045764076836041, -0.5876795935380373),
    LonLat::new(4.823248417427628, 0.9105097136499857),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 108" {
  let vertices = [
    LonLat::new(1.449954820147068, -0.7241300522260092),
    LonLat::new(4.851972039430072, 0.6585480212875051),
    LonLat::new(4.762369535469539, -0.7262045097642943),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 109" {
  let vertices = [
    LonLat::new(1.3543752002515848, 1.131875309445483),
    LonLat::new(0.31450537175987825, 1.504151591101184),
    LonLat::new(1.5132390645377543, -0.3922492455060045),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 110" {
  let vertices = [
    LonLat::new(4.7723069953821184, -0.8381293606307929),
    LonLat::new(1.4985700767066072, 0.9356174638256579),
    LonLat::new(4.809982251773766, 1.0785310136730095),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 111" {
  let vertices = [
    LonLat::new(1.476442930431565, -0.29620617657558185),
    LonLat::new(5.196934278458334, -1.2366994886711824),
    LonLat::new(1.4787577202879967, 0.9821056657848783),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 112" {
  let vertices = [
    LonLat::new(1.5183798754294324, 0.4737465275144945),
    LonLat::new(4.889698830529316, -0.7292463161670047),
    LonLat::new(4.876706705755399, 1.0343623942436528),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 113" {
  let vertices = [
    LonLat::new(1.4066596284775676, 1.1660246104260106),
    LonLat::new(4.807119878429167, 0.46852013295965744),
    LonLat::new(4.86853171275572, 1.0147069382172857),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 114" {
  let vertices = [
    LonLat::new(4.866377549720299, 1.0443308758971852),
    LonLat::new(1.2882333505120642, 0.31078941749672345),
    LonLat::new(1.4924284839746313, 0.06577093548146282),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 115" {
  let vertices = [
    LonLat::new(1.4389166820474613, 0.8498030163715412),
    LonLat::new(1.5038934499117889, 0.8410042913840303),
    LonLat::new(5.460657482158634, -1.4475265555547863),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 116" {
  let vertices = [
    LonLat::new(1.5175866092187567, 0.0016168575676866923),
    LonLat::new(4.89718967765393, 1.075680233210472),
    LonLat::new(1.4488672280437014, 1.1700059875415174),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 117" {
  let vertices = [
    LonLat::new(5.071402049177625, 1.3769513566138054),
    LonLat::new(1.5185431637910045, -0.013497717686979428),
    LonLat::new(1.4394015160622544, -1.0598353096592446),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 118" {
  let vertices = [
    LonLat::new(1.290561418945612, 1.259790942037702),
    LonLat::new(1.3756578366495649, -0.6557054054346886),
    LonLat::new(5.334064500252156, -1.4772186326698815),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 119" {
  let vertices = [
    LonLat::new(4.769557343460679, 0.5294932841238048),
    LonLat::new(4.778617472208243, 0.8842123531194251),
    LonLat::new(4.788301766090591, -0.647969916476432),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 120" {
  let vertices = [
    LonLat::new(1.503314922439111, -0.7754415032308605),
    LonLat::new(1.5016060065754497, -0.8776242670306247),
    LonLat::new(4.794676496691302, 1.0227169442744748),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 121" {
  let vertices = [
    LonLat::new(4.765805885847867, 0.5774629346247763),
    LonLat::new(1.370581043248899, -0.9065034095044098),
    LonLat::new(4.806022219334158, 0.3061394454210802),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 122" {
  let vertices = [
    LonLat::new(1.1623251299528, -1.4345846033173075),
    LonLat::new(4.765627004043493, -0.5458263042058916),
    LonLat::new(1.5058770721820252, -0.3874800514648614),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 123" {
  let vertices = [
    LonLat::new(1.5191497858146519, -0.5182305802731642),
    LonLat::new(1.5166925175096722, 0.4940964542414012),
    LonLat::new(4.831697288971586, -1.0695284833470937),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 124" {
  let vertices = [
    LonLat::new(5.335116328575883, -1.2181635180287393),
    LonLat::new(4.869787532256003, 1.0719936340687581),
    LonLat::new(5.138545606942217, -1.4227406775728288),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 125" {
  let vertices = [
    LonLat::new(1.4318973096949374, 0.20623756201881596),
    LonLat::new(1.5131056387911224, 0.19520325116648504),
    LonLat::new(1.4613503425177359, 1.0910245449761047),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 126" {
  let vertices = [
    LonLat::new(1.5145763758057416, -0.8329668295465625),
    LonLat::new(4.764090631333219, 0.45270696033702507),
    LonLat::new(4.831266753785505, 0.5041948641921029),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 127" {
  let vertices = [
    LonLat::new(4.802656043317951, -1.016428221273991),
    LonLat::new(1.294516963097273, 0.6692386942320322),
    LonLat::new(1.4237384356344611, 1.0013347885756445),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 128" {
  let vertices = [
    LonLat::new(5.0067133126334875, 0.3526522981107514),
    LonLat::new(4.909380918542868, 1.2982412171252955),
    LonLat::new(0.9661938910382653, 1.151793399638533),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 129" {
  let vertices = [
    LonLat::new(1.5134740507997286, -0.3920921714263114),
    LonLat::new(5.542904376952357, 1.4657198458325376),
    LonLat::new(4.7899157798250505, 0.8785490501342282),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 130" {
  let vertices = [
    LonLat::new(0.7405263327731498, 1.3621469551630803),
    LonLat::new(4.81106468367848, -0.9726197805419605),
    LonLat::new(4.764682760522746, 0.2566301845110234),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 131" {
  let vertices = [
    LonLat::new(5.072777240182676, -1.254752291952161),
    LonLat::new(1.4422644074823745, -1.0543497124264245),
    LonLat::new(1.5055307393598256, -0.8690686781022627),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 132" {
  let vertices = [
    LonLat::new(1.4567993654989047, 0.7140209685745831),
    LonLat::new(4.766794527892022, 0.0630164921606553),
    LonLat::new(1.4579017952651079, -0.8024356030143684),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 133" {
  let vertices = [
    LonLat::new(1.22569069835447, -0.7214988025904343),
    LonLat::new(1.4261049950024898, -0.6391409259995886),
    LonLat::new(4.792083388739852, -0.9053666476789582),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 134" {
  let vertices = [
    LonLat::new(4.8969748606158925, -0.45160451737680907),
    LonLat::new(4.7711334269783405, 0.15974924337804086),
    LonLat::new(4.787876668664035, -0.8049688772365895),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 135" {
  let vertices = [
    LonLat::new(4.7740772232995, 0.4266294499742564),
    LonLat::new(4.9109559227722865, -1.292080591423908),
    LonLat::new(1.5019564972825916, -0.4616142183464578),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 136" {
  let vertices = [
    LonLat::new(1.4983040948375987, 0.18741243515111217),
    LonLat::new(4.780962864247574, -0.3399445017790709),
    LonLat::new(4.77248152217679, 0.8455017635710994),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 137" {
  let vertices = [
    LonLat::new(1.4500441194806957, 0.6701465526002148),
    LonLat::new(1.488156941529782, 0.3441145603821196),
    LonLat::new(4.799240820412377, 0.47383157192838715),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 138" {
  let vertices = [
    LonLat::new(1.4916236344304277, 0.7927992864326208),
    LonLat::new(4.781491464956228, -0.3944793709818307),
    LonLat::new(1.4998846175546536, -0.511285573025532),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 139" {
  let vertices = [
    LonLat::new(4.775966462500301, 0.7644974766648187),
    LonLat::new(4.967119979385416, 1.063907288615747),
    LonLat::new(1.4912336961046153, 0.08608086573366454),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 140" {
  let vertices = [
    LonLat::new(1.478583628863099, -1.0439133173412274),
    LonLat::new(1.2253239360899395, -1.3380391597276633),
    LonLat::new(5.540856425769425, -1.1613104255371525),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 141" {
  let vertices = [
    LonLat::new(4.77732590410896, -0.8899292107531531),
    LonLat::new(1.314152182149776, -1.302620362321289),
    LonLat::new(1.4915492515563402, 0.01359926763860898),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 142" {
  let vertices = [
    LonLat::new(1.4688058782070936, -0.7861614348894163),
    LonLat::new(4.983363612983441, 1.1552801086098898),
    LonLat::new(1.2106941092512038, -1.4122911460959926),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 143" {
  let vertices = [
    LonLat::new(0.9091090720344155, 1.4749234410662877),
    LonLat::new(4.841539660684621, -0.9027646607160549),
    LonLat::new(4.763808319208481, 0.1850030163581713),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 144" {
  let vertices = [
    LonLat::new(4.925058999737087, 1.2543919151511365),
    LonLat::new(4.807125570866087, -0.690265961302388),
    LonLat::new(5.230840841652714, -0.6408024915511646),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 145" {
  let vertices = [
    LonLat::new(4.771620625251222, 0.757386055052632),
    LonLat::new(1.5166912038652327, -0.12311784915513763),
    LonLat::new(0.795052667860186, 1.4680887427807707),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 146" {
  let vertices = [
    LonLat::new(1.4350866353990461, 1.1913663792605582),
    LonLat::new(0.699668750574743, -1.3268962724491153),
    LonLat::new(4.765969356259967, -0.3949045260335221),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 147" {
  let vertices = [
    LonLat::new(4.81865501380209, -1.1051206024020022),
    LonLat::new(5.413803395700166, 1.4288849517703825),
    LonLat::new(4.78404335778603, -0.6137936012228732),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 148" {
  let vertices = [
    LonLat::new(4.795431153287935, -0.9451241438626262),
    LonLat::new(1.364827657372599, -1.0831421545135673),
    LonLat::new(1.3603360992308233, -0.10712993470935088),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 149" {
  let vertices = [
    LonLat::new(1.2176605819824402, 1.2093062301150175),
    LonLat::new(1.5098663122674012, -0.4294107571413543),
    LonLat::new(1.4585322687257722, -0.3531962159225284),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 150" {
  let vertices = [
    LonLat::new(4.822031655265938, -0.9437702570011943),
    LonLat::new(1.5100506994334948, 0.7131514231949398),
    LonLat::new(4.85549380684325, 0.6811785998428429),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 151" {
  let vertices = [
    LonLat::new(5.038369949934461, -0.9904265403718864),
    LonLat::new(1.506745283797601, -0.3336379815841212),
    LonLat::new(1.2522255667847602, -0.8722995146833145),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 152" {
  let vertices = [
    LonLat::new(4.786297325892399, 0.2456527940185305),
    LonLat::new(4.768917830208466, 0.4252304257839171),
    LonLat::new(4.789469164037497, 0.8327767026357996),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 153" {
  let vertices = [
    LonLat::new(1.1913113940745224, 1.360695947950589),
    LonLat::new(4.843815576900546, -0.39434282123464387),
    LonLat::new(4.775108655550328, 0.48182941722613987),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 154" {
  let vertices = [
    LonLat::new(1.5207973369342906, -0.379835266469912),
    LonLat::new(0.5357384438513055, -1.4925867712901921),
    LonLat::new(4.823528733684313, 0.4323637550076178),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 155" {
  let vertices = [
    LonLat::new(5.332540610250002, -1.248875082153941),
    LonLat::new(1.4367376800843217, -1.1368262965784826),
    LonLat::new(4.7883740716824645, 0.961020774445334),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 156" {
  let vertices = [
    LonLat::new(4.792587178376747, 0.6839511363224439),
    LonLat::new(4.9916221802455905, 1.2275925552340048),
    LonLat::new(4.78253731787954, 0.8353552090017805),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 157" {
  let vertices = [
    LonLat::new(5.48602800587838, -1.4513090842820673),
    LonLat::new(4.81971574280996, -0.11444669591022553),
    LonLat::new(1.4376615353414384, 0.24807390106219646),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 158" {
  let vertices = [
    LonLat::new(1.5100893286524588, 0.8543891929223606),
    LonLat::new(4.776805630831708, -0.07003191855786804),
    LonLat::new(4.878241527987378, 1.2218112938610453),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 159" {
  let vertices = [
    LonLat::new(4.808280273486005, 0.6436437838061367),
    LonLat::new(4.768386038978919, -0.0546176337468777),
    LonLat::new(1.2118440012020046, -1.1958447630286217),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 160" {
  let vertices = [
    LonLat::new(5.593350609407355, 1.4966616190933444),
    LonLat::new(1.5061907205667104, 0.055421373364258314),
    LonLat::new(1.3607184065112843, -0.5638127347661744),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 161" {
  let vertices = [
    LonLat::new(1.2673844979677336, -1.1844677447118597),
    LonLat::new(1.51248329509886, -0.2718234173187366),
    LonLat::new(1.476725505020479, -1.0607392170482453),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 162" {
  let vertices = [
    LonLat::new(1.2270599243711229, 1.3427461869394),
    LonLat::new(1.044377059356498, 1.428811336042074),
    LonLat::new(1.5058010710837075, 0.590087918398207),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 163" {
  let vertices = [
    LonLat::new(4.821882028140797, -0.7328013749462026),
    LonLat::new(1.353806428902609, -1.2310426359577362),
    LonLat::new(4.820628219300798, 1.066147401052105),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 164" {
  let vertices = [
    LonLat::new(4.7634007656371, 0.1937471665572706),
    LonLat::new(4.774344622226822, -0.6529934015212983),
    LonLat::new(4.788425822919769, 0.850781846651558),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 165" {
  let vertices = [
    LonLat::new(5.414023012346002, -1.3500836134640988),
    LonLat::new(1.485175005569569, -0.3965839501292048),
    LonLat::new(0.7920812149420086, 1.3855357005230906),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 166" {
  let vertices = [
    LonLat::new(1.519886118257947, 0.5345599718560602),
    LonLat::new(1.4999905845201154, 0.8321160117684172),
    LonLat::new(1.5200573123091565, 0.7924292354147618),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 167" {
  let vertices = [
    LonLat::new(1.4662829233923753, 0.33670915720704814),
    LonLat::new(1.518898499647077, -0.6994365863362569),
    LonLat::new(1.5197911906458474, 0.6209001549890557),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 168" {
  let vertices = [
    LonLat::new(6.262905039739623, 1.3234736449226085),
    LonLat::new(1.492820061217197, -0.5260995203071738),
    LonLat::new(4.777248329971482, 0.9102844577961458),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 169" {
  let vertices = [
    LonLat::new(4.766549144571462, 0.7720436655767856),
    LonLat::new(1.503116703310864, -0.6880642777087663),
    LonLat::new(4.77541971732534, 0.3184192464622571),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 170" {
  let vertices = [
    LonLat::new(1.4979222364238043, -0.10917020201323059),
    LonLat::new(4.806161765519638, 1.040532989224642),
    LonLat::new(5.733898610264742, -1.5100990834018082),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 171" {
  let vertices = [
    LonLat::new(1.4947317739164017, 0.49796574169849356),
    LonLat::new(1.4057250114960416, 0.6448519174231866),
    LonLat::new(4.766707084831715, 0.0306745636112464),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 172" {
  let vertices = [
    LonLat::new(1.4893191158471797, 0.16445634875172546),
    LonLat::new(4.791776347088093, 0.2712169107534136),
    LonLat::new(1.4414881878365113, -1.1274884188578165),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 173" {
  let vertices = [
    LonLat::new(1.2825411452946252, 1.1620737164461523),
    LonLat::new(1.184295548751511, 0.5429526795467924),
    LonLat::new(1.4083141013867655, 1.2055484508467345),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 174" {
  let vertices = [
    LonLat::new(4.809809092018384, -0.04810552188641773),
    LonLat::new(1.4945496057154142, 0.2494176928964605),
    LonLat::new(1.515610971023249, 0.11440387637438112),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 175" {
  let vertices = [
    LonLat::new(1.5126721259851164, -0.05097539293121654),
    LonLat::new(1.5125879813993757, 0.7156067637753063),
    LonLat::new(4.766040196608039, -0.3023219930447228),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 176" {
  let vertices = [
    LonLat::new(5.124139943737932, 1.3362483497092668),
    LonLat::new(4.779481472570384, -0.6920445304629822),
    LonLat::new(1.4965969084682957, -0.4471540689233016),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 177" {
  let vertices = [
    LonLat::new(1.4324090302081518, -1.1234180589015923),
    LonLat::new(1.4426484103754842, 0.23226095571583366),
    LonLat::new(4.776750946842169, -0.44376019553561835),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 178" {
  let vertices = [
    LonLat::new(4.807545337073563, -0.7283638352316976),
    LonLat::new(4.776851777846858, 0.4255612650328268),
    LonLat::new(4.804888433939647, 0.7158052990221137),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 179" {
  let vertices = [
    LonLat::new(4.765751229911309, -0.05331490938825895),
    LonLat::new(1.4797119023491145, 0.6478960921554505),
    LonLat::new(1.5200962834897007, -0.679583359317263),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 180" {
  let vertices = [
    LonLat::new(1.4124614048264779, 1.197640942149886),
    LonLat::new(1.504865410264391, -0.47746468028898303),
    LonLat::new(1.4859428970080728, 0.6136595648054649),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 181" {
  let vertices = [
    LonLat::new(1.5035347813985516, 0.3481983415018102),
    LonLat::new(4.8488420814111235, 1.0341881327201057),
    LonLat::new(1.499728410421935, 0.8963444879432133),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 182" {
  let vertices = [
    LonLat::new(4.772144256897798, 0.17907912012019436),
    LonLat::new(1.427916867121994, -1.133572181184087),
    LonLat::new(4.777767224016738, 0.27666591554513525),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 183" {
  let vertices = [
    LonLat::new(1.5049666272737634, -0.8057650466951112),
    LonLat::new(4.902323015164949, 0.10800848317330235),
    LonLat::new(1.5045771320217265, 0.5867096136662163),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 184" {
  let vertices = [
    LonLat::new(4.912958797820201, 0.10545251262884493),
    LonLat::new(1.4508167614413188, -0.43957414570984854),
    LonLat::new(4.787485491060279, 0.10367996323156228),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 185" {
  let vertices = [
    LonLat::new(4.871160555006432, -1.07827453895899),
    LonLat::new(1.4844676366546201, 0.757312048462351),
    LonLat::new(1.4369568460579965, 0.20045881785249126),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 186" {
  let vertices = [
    LonLat::new(1.36290261624388, 0.9930047962260085),
    LonLat::new(4.776868183937124, -0.7687560103048325),
    LonLat::new(0.8596662981466908, -0.655444220783133),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 187" {
  let vertices = [
    LonLat::new(1.5091882912962786, -0.8517740268057988),
    LonLat::new(1.5162454763564133, 0.43578653641942905),
    LonLat::new(4.7667717864237975, -0.7646378860105856),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 188" {
  let vertices = [
    LonLat::new(1.125963675872445, -1.4308911123114725),
    LonLat::new(4.765099416972427, -0.2071093299563609),
    LonLat::new(4.975984967337947, -1.353416018031006),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 189" {
  let vertices = [
    LonLat::new(1.4891549573851521, 0.951878622516833),
    LonLat::new(1.3575132082101629, 0.8647982451619971),
    LonLat::new(4.780921062741983, -0.3692934484799664),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 190" {
  let vertices = [
    LonLat::new(0.383548193628736, 1.0862820033973133),
    LonLat::new(1.49285197462316, 0.9607972801755859),
    LonLat::new(1.39213363073718, 0.18991817703261232),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 191" {
  let vertices = [
    LonLat::new(4.801932278416451, 0.9049900469803057),
    LonLat::new(4.816881708067424, -0.3432384578081936),
    LonLat::new(1.4772944662994414, -0.6322648311242415),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 192" {
  let vertices = [
    LonLat::new(0.6428053114038623, 1.48165099802273),
    LonLat::new(4.8712553581358975, -0.8295674205868311),
    LonLat::new(4.959402809028483, 0.19597308239308708),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 193" {
  let vertices = [
    LonLat::new(1.4954006880550346, -0.8889746723831393),
    LonLat::new(4.78351432937993, -0.07065076394680803),
    LonLat::new(1.5121838743713603, -0.5200562707506318),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 194" {
  let vertices = [
    LonLat::new(4.768288718974412, -0.8083687073839809),
    LonLat::new(1.4047328788745153, -0.33347796496439),
    LonLat::new(1.4989797800975804, 0.06558100813241048),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 195" {
  let vertices = [
    LonLat::new(5.932846073861088, -1.28621875152683),
    LonLat::new(1.4834632433611328, 0.3434157204720614),
    LonLat::new(4.873476392357363, 1.1467297227562645),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 196" {
  let vertices = [
    LonLat::new(4.802056641171932, -0.9282865058471481),
    LonLat::new(4.764561562762477, 0.6690101919994733),
    LonLat::new(1.4493172003154648, -0.6873807663559728),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 197" {
  let vertices = [
    LonLat::new(4.891634793781397, -0.5709112909875697),
    LonLat::new(4.767924076127649, 0.09806950725924964),
    LonLat::new(1.517577989982407, -0.7771249651840518),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 198" {
  let vertices = [
    LonLat::new(1.41657975468647, 0.6003981425289789),
    LonLat::new(1.4467354157913352, -1.0206982669399607),
    LonLat::new(4.824664372312112, -1.0753903587030398),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}

///|
test "independent open hemisphere triangle 199" {
  let vertices = [
    LonLat::new(4.792291460909951, 0.9194484851440181),
    LonLat::new(4.800798372312363, 0.6348051507980941),
    LonLat::new(4.773114453229183, 0.4948509102132883),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for vertex in vertices {
    assert_true(polygon.contains(vertex))
  }
}
