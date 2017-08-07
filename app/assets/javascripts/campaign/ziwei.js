var Zwds = function() {
	Number.prototype.mod = function(n) { return ((this%n)+n)%n; }
	var JQ24 = function() {
		var ptsa = new Array(485, 203, 199, 182, 156, 136, 77, 74, 70, 58, 52, 50, 45, 44, 29, 18, 17, 16, 14, 12, 12, 12, 9, 8);
		var ptsb = new Array(324.96, 337.23, 342.08, 27.85, 73.14, 171.52, 222.54, 296.72, 243.58, 119.81, 297.17, 21.02, 247.54, 325.15, 60.93, 155.12, 288.79, 198.04, 199.76, 95.39, 287.11, 320.81, 227.73, 15.45);
		var ptsc = new Array(1934.136, 32964.467, 20.186, 445267.112, 45036.886, 22518.443, 65928.934, 3034.906, 9037.513, 33718.147, 150.678, 2281.226, 29929.562, 31555.956, 4443.417, 67555.328, 4562.452, 62894.029, 31436.921, 14577.848, 31931.756, 34777.259, 1222.114, 16859.074);

		this.VE = function(yy) {
			var yx = yy;
			if (yx >= 1000 && yx <= 8001) {
				var m = (yx - 2000) / 1000;
				jdve = 2451623.80984 + 365242.37404 * m + 0.05169 * m * m - 0.00411 * m * m * m - 0.00057 * m * m * m * m;
			} else {
				if (yx >= -8000 && yx < 1000) {
					m = yx / 1000;
					jdve = 1721139.29189 + 365242.1374 * m + 0.06134 * m * m + 0.00111 * m * m * m - 0.00071 * m * m * m * m;
				} else {
					alert("超出計算能力範圍");
					return false;
				}
			}
			return jdve
		}
		this.MeanJQJD = function(yy, jdve, ty, ini, num) {
			var ath = 2 * Math.PI / 24;
			var tx = (jdve - 2451545) / 365250;
			var e = 0.0167086342 - 0.0004203654 * tx - 0.0000126734 * tx * tx + 0.0000001444 * tx * tx * tx - 0.0000000002 * tx * tx * tx * tx + 0.0000000003 * tx * tx * tx * tx * tx;
			var tt = yy / 1000;
			var vp = 111.25586939 - 17.0119934518333 * tt - 0.044091890166673 * tt * tt - 4.37356166661345E-04 * tt * tt * tt + 8.16716666602386E-06 * tt * tt * tt * tt;
			var rvp = vp * 2 * Math.PI / 360;
			var peri = new Array(30);
			var i;
			for (i = 1; i <= (ini + num); i++) {
				var flag = 0;
				var th = ath * (i - 1) + rvp;
				if (th > Math.PI && th <= 3 * Math.PI) {
					th = 2 * Math.PI - th;
					flag = 1;
				}
				if (th > 3 * Math.PI) {
					th = 4 * Math.PI - th;
					flag = 2;
				}
				var f1 = 2 * Math.atan((Math.sqrt((1 - e) / (1 + e)) * Math.tan(th / 2)));
				var f2 = (e * Math.sqrt(1 - e * e) * Math.sin(th)) / (1 + e * Math.cos(th));
				var f = (f1 - f2) * ty / 2 / Math.PI;
				if (flag == 1) f = ty - f;
				if (flag == 2) f = 2 * ty - f;
				peri[i] = f;
			}
			var jdez = new Array(30);
			for (i = ini; i <= (ini + num); i++) {
				jdez[i] = jdve + peri[i] - peri[1];
			}
			return jdez;
		}
		this.Perturbation = function(jdez) {
			var t = (jdez - 2451545) / 36525;
			var s = 0;
			for (k = 0; k <= 23; k++) {
				s = s + ptsa[k] * Math.cos(ptsb[k] * 2 * Math.PI / 360 + ptsc[k] * 2 * Math.PI / 360 * t);
			}
			var w = 35999.373 * t - 2.47;
			var l = 1 + 0.0334 * Math.cos(w * 2 * Math.PI / 360) + 0.0007 * Math.cos(2 * w * 2 * Math.PI / 360);
			var ptb = 0.00001 * s / l;
			return ptb;
		}
		this.DeltaT = function(yy, mm) {
			var u, t, dt, y;
			y = yy + (mm - 0.5) / 12;

			if (y <= -500) {
				u = (y - 1820) / 100;
				dt = (-20 + 32 * u * u);
			} else {
				if (y < 500) {
					u = y / 100;
					dt = (10583.6 - 1014.41 * u + 33.78311 * u * u - 5.952053 * u * u * u - 0.1798452 * u * u * u * u + 0.022174192 * u * u * u * u * u + 0.0090316521 * u * u * u * u * u * u);
				} else {
					if (y < 1600) {
						u = (y - 1000) / 100;
						dt = (1574.2 - 556.01 * u + 71.23472 * u * u + 0.319781 * u * u * u - 0.8503463 * u * u * u * u - 0.005050998 * u * u * u * u * u + 0.0083572073 * u * u * u * u * u * u);
					} else {
						if (y < 1700) {
							t = y - 1600;
							dt = (120 - 0.9808 * t - 0.01532 * t * t + t * t * t / 7129);
						} else {
							if (y < 1800) {
								t = y - 1700;
								dt = (8.83 + 0.1603 * t - 0.0059285 * t * t + 0.00013336 * t * t * t - t * t * t * t / 1174000);
							} else {
								if (y < 1860) {
									t = y - 1800;
									dt = (13.72 - 0.332447 * t + 0.0068612 * t * t + 0.0041116 * t * t * t - 0.00037436 * t * t * t * t + 0.0000121272 * t * t * t * t * t - 0.0000001699 * t * t * t * t * t * t + 0.000000000875 * t * t * t * t * t * t * t);
								} else {
									if (y < 1900) {
										t = y - 1860;
										dt = (7.62 + 0.5737 * t - 0.251754 * t * t + 0.01680668 * t * t * t - 0.0004473624 * t * t * t * t + t * t * t * t * t / 233174);
									} else {
										if (y < 1920) {
											t = y - 1900;
											dt = (-2.79 + 1.494119 * t - 0.0598939 * t * t + 0.0061966 * t * t * t - 0.000197 * t * t * t * t);
										} else {
											if (y < 1941) {
												t = y - 1920;
												dt = (21.2 + 0.84493 * t - 0.0761 * t * t + 0.0020936 * t * t * t);
											} else {
												if (y < 1961) {
													t = y - 1950;
													dt = (29.07 + 0.407 * t - t * t / 233 + t * t * t / 2547);
												} else {
													if (y < 1986) {
														t = y - 1975;
														dt = (45.45 + 1.067 * t - t * t / 260 - t * t * t / 718);
													} else {
														if (y < 2005) {
															t = y - 2000;
															dt = (63.86 + 0.3345 * t - 0.060374 * t * t + 0.0017275 * t * t * t + 0.000651814 * t * t * t * t + 0.00002373599 * t * t * t * t * t);
														} else {
															if (y < 2050) {
																t = y - 2000;
																dt = (62.92 + 0.32217 * t + 0.005589 * t * t);
															} else {
																if (y < 2150) {
																	u = (y - 1820) / 100;
																	dt = (-20 + 32 * u * u - 0.5628 * (2150 - y));
																} else {
																	u = (y - 1820) / 100;
																	dt = (-20 + 32 * u * u);
																}
															}
														}
													}
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}

			if (y < 1955 || y >= 2005) dt = dt - (0.000012932 * (y - 1955) * (y - 1955));
			var DeltaT = dt / 60;
			return DeltaT
		}
	}
	var jq24 = new JQ24();
	var VE = jq24.VE;
	var MeanJQJD = jq24.MeanJQJD;
	var Perturbation = jq24.Perturbation;
	var DeltaT = jq24.DeltaT;

	var synmonth = 29.530588853;

	var Jdays = function(op, yr, mh, dy, hr) {
		if (yr < -400000 || yr > 400000) return false;
		var yp = yr + Math.floor((mh - 3) / 10);
		if (((yr > 1582) || (yr == 1582 && mh > 10) || (yr == 1582 && mh == 10 && dy >= 15)) || op) {
			var init = 1721119.5;
			var jdy = Math.floor(yp * 365.25) - Math.floor(yp / 100) + Math.floor(yp / 400);
		} else {
			if ((yr < 1582) || (yr == 1582 && mh < 10) || (yr == 1582 && mh == 10 && dy <= 4)) {
				var init = 1721117.5;
				var jdy = Math.floor(yp * 365.25);
			} else {
				return false;
			}
		}
		var mp = Math.floor(mh + 9) % 12;
		var jdm = mp * 30 + Math.floor((mp + 1) * 34 / 57);
		var jdd = dy - 1;
		var jdh = hr / 24;
		var jd = jdy + jdm + jdd + jdh + init;
		return jd;
	}

	var GetAdjustedJQ = function(yy, ini, num, jdjq) {
		var veb = VE(yy);
		var ty = VE(yy + 1) - veb;

		var jdez = MeanJQJD(yy, veb, ty, ini, num);
		for (i = ini + 1; i <= (ini + num); i++) {
			var ptb = Perturbation(jdez[i]);
			var dt = DeltaT(yy, Math.floor(i / 2) + 3);
			jdjq[i] = jdez[i] + ptb - dt / 60 / 24;
			jdjq[i] = jdjq[i] + 1 / 3;
		}
	}

	var GetZQsinceWinterSolstice = function(yy, jdzq) {
		var dj = new Array(26);
		GetAdjustedJQ(yy - 1, 18, 5, dj);
		jdzq[0] = dj[19];
		jdzq[1] = dj[21];
		jdzq[2] = dj[23];
		GetAdjustedJQ(yy, 0, 26, dj);
		for (i = 1; i <= 13; i++) {
			jdzq[i + 2] = dj[2 * i - 1];
		}
	}

	var MeanNewMoon = function(jd) {
		var t, thejd, jdt;
		var k = Math.floor((jd - 2451550.09765) / synmonth);
		jdt = 2451550.09765 + k * synmonth;
		t = (jdt - 2451545) / 36525;
		thejd = jdt + 0.0001337 * t * t - 0.00000015 * t * t * t + 0.00000000073 * t * t * t * t;
		return k;
	}

	var TrueNewMoon = function(k) {
		var t, t2, t3, t4;
		var m, mprime, f, omega, es;
		var pt, apt1, apt2, jdt;
		jdt = 2451550.09765 + k * synmonth;
		t = (jdt - 2451545) / 36525;
		t2 = t * t;
		t3 = t2 * t;
		t4 = t3 * t;
		pt = jdt + 0.0001337 * t2 - 0.00000015 * t3 + 0.00000000073 * t4;
		m = 2.5534 + 29.10535669 * k - 0.0000218 * t2 - 0.00000011 * t3;
		mprime = 201.5643 + 385.81693528 * k + 0.0107438 * t2 + 0.00001239 * t3 - 0.000000058 * t4;
		f = 160.7108 + 390.67050274 * k - 0.0016341 * t2 - 0.00000227 * t3 + 0.000000011 * t4;
		omega = 124.7746 - 1.5637558 * k + 0.0020691 * t2 + 0.00000215 * t3;
		es = 1 - 0.002516 * t - 0.0000074 * t2;
		apt1 = -0.4072 * Math.sin((Math.PI / 180) * mprime);
		apt1 += 0.17241 * es * Math.sin((Math.PI / 180) * m);
		apt1 += 0.01608 * Math.sin((Math.PI / 180) * 2 * mprime);
		apt1 += 0.01039 * Math.sin((Math.PI / 180) * 2 * f);
		apt1 += 0.00739 * es * Math.sin((Math.PI / 180) * (mprime - m));
		apt1 -= 0.00514 * es * Math.sin((Math.PI / 180) * (mprime + m));
		apt1 += 0.00208 * es * es * Math.sin((Math.PI / 180) * (2 * m));
		apt1 -= 0.00111 * Math.sin((Math.PI / 180) * (mprime - 2 * f));
		apt1 -= 0.00057 * Math.sin((Math.PI / 180) * (mprime + 2 * f));
		apt1 += 0.00056 * es * Math.sin((Math.PI / 180) * (2 * mprime + m));
		apt1 -= 0.00042 * Math.sin((Math.PI / 180) * 3 * mprime);
		apt1 += 0.00042 * es * Math.sin((Math.PI / 180) * (m + 2 * f));
		apt1 += 0.00038 * es * Math.sin((Math.PI / 180) * (m - 2 * f));
		apt1 -= 0.00024 * es * Math.sin((Math.PI / 180) * (2 * mprime - m));
		apt1 -= 0.00017 * Math.sin((Math.PI / 180) * omega);
		apt1 -= 0.00007 * Math.sin((Math.PI / 180) * (mprime + 2 * m));
		apt1 += 0.00004 * Math.sin((Math.PI / 180) * (2 * mprime - 2 * f));
		apt1 += 0.00004 * Math.sin((Math.PI / 180) * (3 * m));
		apt1 += 0.00003 * Math.sin((Math.PI / 180) * (mprime + m - 2 * f));
		apt1 += 0.00003 * Math.sin((Math.PI / 180) * (2 * mprime + 2 * f));
		apt1 -= 0.00003 * Math.sin((Math.PI / 180) * (mprime + m + 2 * f));
		apt1 += 0.00003 * Math.sin((Math.PI / 180) * (mprime - m + 2 * f));
		apt1 -= 0.00002 * Math.sin((Math.PI / 180) * (mprime - m - 2 * f));
		apt1 -= 0.00002 * Math.sin((Math.PI / 180) * (3 * mprime + m));
		apt1 += 0.00002 * Math.sin((Math.PI / 180) * (4 * mprime));

		apt2 = 0.000325 * Math.sin((Math.PI / 180) * (299.77 + 0.107408 * k - 0.009173 * t2));
		apt2 += 0.000165 * Math.sin((Math.PI / 180) * (251.88 + 0.016321 * k));
		apt2 += 0.000164 * Math.sin((Math.PI / 180) * (251.83 + 26.651886 * k));
		apt2 += 0.000126 * Math.sin((Math.PI / 180) * (349.42 + 36.412478 * k));
		apt2 += 0.00011 * Math.sin((Math.PI / 180) * (84.66 + 18.206239 * k));
		apt2 += 0.000062 * Math.sin((Math.PI / 180) * (141.74 + 53.303771 * k));
		apt2 += 0.00006 * Math.sin((Math.PI / 180) * (207.14 + 2.453732 * k));
		apt2 += 0.000056 * Math.sin((Math.PI / 180) * (154.84 + 7.30686 * k));
		apt2 += 0.000047 * Math.sin((Math.PI / 180) * (34.52 + 27.261239 * k));
		apt2 += 0.000042 * Math.sin((Math.PI / 180) * (207.19 + 0.121824 * k));
		apt2 += 0.00004 * Math.sin((Math.PI / 180) * (291.34 + 1.844379 * k));
		apt2 += 0.000037 * Math.sin((Math.PI / 180) * (161.72 + 24.198154 * k));
		apt2 += 0.000035 * Math.sin((Math.PI / 180) * (239.56 + 25.513099 * k));
		apt2 += 0.000023 * Math.sin((Math.PI / 180) * (331.55 + 3.592518 * k));
		var tnm = pt + apt1 + apt2;
		return tnm;
	}

	var GetSMsinceWinterSolstice = function(op, yy, jdws, jdnm) {
		var kn, tjd = new Array,
			i, k, mjd, thejd;
		var spcjd, phase, kn;
		spcjd = Jdays(op, yy - 1, 11, 0, 0);
		kn = MeanNewMoon(spcjd);
		for (i = 0; i <= 19; i++) {
			k = kn + i;
			mjd = thejd + synmonth * i;
			tjd[i] = TrueNewMoon(k) + 1 / 3;
			tjd[i] = tjd[i] - DeltaT(yy, i - 1) / 1440;
		}
		for (j = 0; j <= 18; j++) {
			if (Math.floor(tjd[j] + 0.5) > Math.floor(jdws + 0.5)) {
				break;
			}
		}
		jj = j;
		for (k = 0; k <= 15; k++) {
			jdnm[k] = tjd[jj - 1 + k];
		}
	}

	var GetZQandSMandLunarMonthCode = function(op, yy, jdzq, jdnm, mc) {
		var yz;
		GetZQsinceWinterSolstice(yy, jdzq);
		GetSMsinceWinterSolstice(op, yy, jdzq[0], jdnm);

		yz = 0;
		if (Math.floor(jdzq[12] + 0.5) >= Math.floor(jdnm[13] + 0.5)) {
			for (i = 1; i <= 14; i++) {
				if (Math.floor((jdnm[i] + 0.5) > Math.floor(jdzq[i - 1 - yz] + 0.5) && Math.floor(jdnm[i + 1] + 0.5) <= Math.floor(jdzq[i - yz] + 0.5))) {
					mc[i] = i - 0.5;
					yz = 1;
				} else {
					mc[i] = i - yz;
				}
			}
		} else {
			for (i = 0; i <= 12; i++) {
				mc[i] = i;
			}
			for (i = 13; i <= 14; i++) {
				if (Math.floor((jdnm[i] + 0.5) > Math.floor(jdzq[i - 1 - yz] + 0.5) && Math.floor(jdnm[i + 1] + 0.5) <= Math.floor(jdzq[i - yz] + 0.5))) {
					mc[i] = i - 0.5;
					yz = 1;
				} else {
					mc[i] = i - yz;
				}
			}
		}
	}

	var ValidDate = function(op, yy, mm, dd) {
		var vd = true;
		if (mm <= 0 || mm > 12) {
			alert("月份超出範圍");
			vd = false;
		} else {
			var ndf1 = -(yy % 4 == 0);
			var ndf2 = ((yy % 400 == 0) - (yy % 100 == 0)) && (((yy > 1582) && (!op)) || op);
			var ndf = ndf1 + ndf2;
			var dom = 30 + ((Math.abs(mm - 7.5) + 0.5) % 2) - (mm == 2) * (2 + ndf);
			if (dd <= 0 || dd > dom) {
				if (ndf == 0 && mm == 2 && dd == 29) {
					alert("此年無閏月");
				} else {
					alert("日期超出範圍");
				}
				vd = false;
			}
		}
		if ((yy == 1582 && mm == 10 && dd >= 5 && dd < 15) && !op) {
			alert("此日期不存在");
			vd = false;
		}
		return vd;
	}

	this.getLunar = function(op, yea, mx, dx) {
		if (ValidDate(op, yea, mx, dx) == false) {
			return false;
		}
		if (yea == 1919 && mx == 1 && dx == 1) {
			return {ly: 1918, lm: 11, ld: 30, ry: false };
		}
		if (yea == 1938 && mx == 1 && dx == 1) {
			return {ly: 1937, lm: 11, ld: 30, ry: false };
		}
		if (yea == 1984 && mx == 1 && dx == 1) {
			return {ly: 1983, lm: 11, ld: 29, ry: false };
		}
		if (yea == 1984 && mx == 1 && dx == 2) {
			return {ly: 1983, lm: 11, ld: 30, ry: false };
		}
		if (yea == 2052 && mx == 1 && dx == 1) {
			return {ly: 2051, lm: 11, ld: 30, ry: false };
		}

		var zr = new Array;
		var sjd = new Array;
		var mc = new Array;
		var flag = 0;

		GetZQandSMandLunarMonthCode(op, yea, zr, sjd, mc);

		var jdx = Jdays(op, yea, mx, dx, 12);
		if (Math.floor(jdx) < Math.floor(sjd[0] + 0.5)) {
			flag = 1;
			GetZQandSMandLunarMonthCode(op, yea - 1, zr, sjd, mc);
		}
		for (i = 0; i <= 14; i++) {
			if (Math.floor(jdx) >= Math.floor(sjd[i] + 0.5) && Math.floor(jdx) < Math.floor(sjd[i + 1] + 0.5)) {
				mi = i;
				break;
			}
		}
		var dz = Math.floor(jdx) - Math.floor(sjd[mi] + 0.5) + 1;
		var yi;
		if (mc[mi] < 2 || flag == 1) {
			yi = yea - 1
		} else {
			yi = yea;
		}
		var ry = !((mc[mi] - Math.floor(mc[mi])) * 2 + 1 == 1);
		var mis = (Math.floor(mc[mi] + 10) % 12) + 1;
		return {
			ly: yi,
			lm: mis,
			ld: dz,
			ry: ry
		};
	}
	var ZwdsChart = function(ly, lm, ld, lh) {
		var Palace = function(palace) {
			this.palace = palace;
			this.stars = new Array();
		}
		Palace.prototype.setHouse = function(house) {
			this.house = house;
		}
		Palace.prototype.setPalaceStem = function(stem) {
			this.palaceStem = stem;
		}
		Palace.prototype.addStar = function(star) {
			this.stars.push(star);
		}

		this.ly = ly;
		this.lm = lm;
		this.ld = ld;
		this.lh = lh;
		this.eb = Math.floor(lh/2);
		this.ySC = this._getYearSC(ly);
		this.stars = new Array(14);
		this.selfHouse = (0 + (lm-1) - this.eb).mod(12);
		this.bodyHouse = (0 + (lm-1) + this.eb) % 12;

		var palaceStem = (this.ySC.stem + 1) % 5 * 2;
		this.fateplate = new Array(12);
		for (var i = 0; i < 12; i++) {
			var palace = new Palace( (i + 2) % 12 );
			palace.setHouse( (this.selfHouse - i).mod(12) );
			palace.setPalaceStem( (palaceStem + i) % 10 );
			this.fateplate[i] = palace;
		};

		var selfHouse = this.fateplate[this.selfHouse];
		this.wuXing = this._getWuXing( selfHouse.palaceStem, selfHouse.palace );

		var inning = this.wuXing + 2;
		var map = [11,2,9,4,7];
		var remainder = ld.mod(inning);
		var quotient = Math.floor(ld/inning);
		var ziwei = 0;
		if ( 0 == remainder ) {
			ziwei = quotient - 1;
		} else {
			ziwei = map[inning - remainder - 1] + quotient;
		};
		ziwei = ziwei % 12;
		var ziweiGalaxy = [0,1,3,4,5,8];
		for (var i = 0; i < 6; i++) {
			var loc = (ziwei - ziweiGalaxy[i]).mod(12);
			this.stars[i] = loc;
			this.fateplate[loc].addStar(i);
		};

		var tianfu = (12 - ziwei) % 12;
		var tianfuGalaxy = [0,1,2,3,4,5,6,10];
		for (var i = 0; i < 8; i++) {
			var loc = (tianfu + tianfuGalaxy[i]).mod(12);
			var star_inx = 6 + i;
			this.stars[star_inx] = loc;
			this.fateplate[loc].addStar(star_inx);
		};
	}
	ZwdsChart.prototype._getYearSC = function(year) {
		var offset = (year-4).mod(60);
		return {
			stem: offset.mod(10),
			branch: offset.mod(12)
		};
	}
	ZwdsChart.prototype._getWuXing = function(stem, branch) {
		var wuXingInning = [2,4,1,3,2, 4,0,3,2,1, 0,3,4,1,0];
		var year = Math.floor( (stem - branch).mod(10) / 2 )*12 + branch;
		return wuXingInning[ Math.floor(year/2).mod(15) ];
	}
	ZwdsChart.prototype.strStar = ['紫微','天機','太陽','武曲','天同','廉貞','天府','太陰','貪狼','巨門','天相','天梁','七殺','破軍'];
	ZwdsChart.prototype.strBranch = ['子','丑','寅','卯','辰','巳','午','未','申','酉','戌','亥'];
	ZwdsChart.prototype.getSelfPalaceName = function() {
		return this.strBranch[(this.selfHouse+2) % 12];
	}
	ZwdsChart.prototype.getSelfStars = function(inx) {
		return this.getHouseStars(this.selfHouse);
	}
	ZwdsChart.prototype.getTravelStars = function(inx) {
		return this.getHouseStars((this.selfHouse+6).mod(12));
	}
	ZwdsChart.prototype.getHouseStars = function(inx) {
		var palace = this.fateplate[inx];
		var stars = [];
		for (var s in palace.stars) {
			stars[s] = palace.stars[s];
		}
		return stars;
	}
	this.getChart = function(yea, mx, dx, hour) {
		if (23 == hour) {
			hour = 0;
			var cur_date = new Date(yea, mx-1, dx);
			var next_date = new Date(cur_date.getTime()+86400000);
			yea = next_date.getFullYear();
			mx = next_date.getMonth()+1;
			dx = next_date.getDate();
		}
		var lunar = this.getLunar(false, yea, mx, dx);
		if (false == lunar) {
			return false;
		}
		return new ZwdsChart(lunar.ly, lunar.lm, lunar.ld, hour);
	}
}
