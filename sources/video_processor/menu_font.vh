function [15:0] menu_glyph_row;
    input [6:0] gid;
    input [3:0] grow;
    begin
        case ({gid, grow})
            11'd18  : menu_glyph_row = 16'h0820;
            11'd19  : menu_glyph_row = 16'h1860;
            11'd20  : menu_glyph_row = 16'h3CFC;
            11'd21  : menu_glyph_row = 16'h1040;
            11'd22  : menu_glyph_row = 16'h29FC;
            11'd23  : menu_glyph_row = 16'h2CC0;
            11'd24  : menu_glyph_row = 16'h3CC0;
            11'd25  : menu_glyph_row = 16'h0878;
            11'd26  : menu_glyph_row = 16'h1E10;
            11'd27  : menu_glyph_row = 16'h28B0;
            11'd28  : menu_glyph_row = 16'h0860;
            11'd29  : menu_glyph_row = 16'h0810;
            11'd34  : menu_glyph_row = 16'h09F8;
            11'd35  : menu_glyph_row = 16'h0810;
            11'd36  : menu_glyph_row = 16'h0820;
            11'd37  : menu_glyph_row = 16'h3CC0;
            11'd38  : menu_glyph_row = 16'h19FC;
            11'd39  : menu_glyph_row = 16'h08D4;
            11'd40  : menu_glyph_row = 16'h0894;
            11'd41  : menu_glyph_row = 16'h08A4;
            11'd42  : menu_glyph_row = 16'h0F24;
            11'd43  : menu_glyph_row = 16'h3264;
            11'd44  : menu_glyph_row = 16'h00C4;
            11'd45  : menu_glyph_row = 16'h0198;
            11'd50  : menu_glyph_row = 16'h0040;
            11'd51  : menu_glyph_row = 16'h17FC;
            11'd52  : menu_glyph_row = 16'h1040;
            11'd53  : menu_glyph_row = 16'h03F8;
            11'd54  : menu_glyph_row = 16'h0248;
            11'd55  : menu_glyph_row = 16'h33F8;
            11'd56  : menu_glyph_row = 16'h10C0;
            11'd57  : menu_glyph_row = 16'h11D0;
            11'd58  : menu_glyph_row = 16'h1348;
            11'd59  : menu_glyph_row = 16'h1640;
            11'd60  : menu_glyph_row = 16'h1800;
            11'd61  : menu_glyph_row = 16'h27FC;
            11'd66  : menu_glyph_row = 16'h0080;
            11'd67  : menu_glyph_row = 16'h1FF8;
            11'd68  : menu_glyph_row = 16'h1000;
            11'd69  : menu_glyph_row = 16'h1330;
            11'd70  : menu_glyph_row = 16'h17F8;
            11'd71  : menu_glyph_row = 16'h1320;
            11'd72  : menu_glyph_row = 16'h11E0;
            11'd73  : menu_glyph_row = 16'h17F0;
            11'd74  : menu_glyph_row = 16'h1330;
            11'd75  : menu_glyph_row = 16'h3120;
            11'd76  : menu_glyph_row = 16'h20C0;
            11'd77  : menu_glyph_row = 16'h2F3C;
            11'd82  : menu_glyph_row = 16'h0180;
            11'd83  : menu_glyph_row = 16'h1FFC;
            11'd85  : menu_glyph_row = 16'h0C30;
            11'd86  : menu_glyph_row = 16'h0FF0;
            11'd88  : menu_glyph_row = 16'h3FFC;
            11'd89  : menu_glyph_row = 16'h2004;
            11'd90  : menu_glyph_row = 16'h03C0;
            11'd91  : menu_glyph_row = 16'h0640;
            11'd92  : menu_glyph_row = 16'h0444;
            11'd93  : menu_glyph_row = 16'h187C;
            11'd98  : menu_glyph_row = 16'h0008;
            11'd99  : menu_glyph_row = 16'h0008;
            11'd100 : menu_glyph_row = 16'h3E08;
            11'd101 : menu_glyph_row = 16'h03FC;
            11'd102 : menu_glyph_row = 16'h2208;
            11'd103 : menu_glyph_row = 16'h1488;
            11'd104 : menu_glyph_row = 16'h0C88;
            11'd105 : menu_glyph_row = 16'h0C48;
            11'd106 : menu_glyph_row = 16'h0E08;
            11'd107 : menu_glyph_row = 16'h1208;
            11'd108 : menu_glyph_row = 16'h3008;
            11'd109 : menu_glyph_row = 16'h0030;
            11'd114 : menu_glyph_row = 16'h1080;
            11'd115 : menu_glyph_row = 16'h1080;
            11'd116 : menu_glyph_row = 16'h108C;
            11'd117 : menu_glyph_row = 16'h1098;
            11'd118 : menu_glyph_row = 16'h1EE0;
            11'd119 : menu_glyph_row = 16'h1080;
            11'd120 : menu_glyph_row = 16'h1080;
            11'd121 : menu_glyph_row = 16'h1080;
            11'd122 : menu_glyph_row = 16'h1080;
            11'd123 : menu_glyph_row = 16'h1684;
            11'd124 : menu_glyph_row = 16'h38CC;
            11'd125 : menu_glyph_row = 16'h0078;
            11'd130 : menu_glyph_row = 16'h0200;
            11'd131 : menu_glyph_row = 16'h07E0;
            11'd132 : menu_glyph_row = 16'h0840;
            11'd133 : menu_glyph_row = 16'h1840;
            11'd134 : menu_glyph_row = 16'h3FF8;
            11'd135 : menu_glyph_row = 16'h0890;
            11'd136 : menu_glyph_row = 16'h0890;
            11'd137 : menu_glyph_row = 16'h0FF8;
            11'd138 : menu_glyph_row = 16'h0800;
            11'd139 : menu_glyph_row = 16'h0800;
            11'd140 : menu_glyph_row = 16'h0804;
            11'd141 : menu_glyph_row = 16'h0FF8;
            11'd146 : menu_glyph_row = 16'h13F8;
            11'd147 : menu_glyph_row = 16'h1A18;
            11'd148 : menu_glyph_row = 16'h03F8;
            11'd149 : menu_glyph_row = 16'h2218;
            11'd150 : menu_glyph_row = 16'h1218;
            11'd153 : menu_glyph_row = 16'h17F8;
            11'd154 : menu_glyph_row = 16'h14A8;
            11'd155 : menu_glyph_row = 16'h34A8;
            11'd156 : menu_glyph_row = 16'h24A8;
            11'd157 : menu_glyph_row = 16'h2FFC;
            11'd161 : menu_glyph_row = 16'h11FC;
            11'd162 : menu_glyph_row = 16'h0904;
            11'd163 : menu_glyph_row = 16'h0124;
            11'd164 : menu_glyph_row = 16'h0174;
            11'd165 : menu_glyph_row = 16'h3924;
            11'd166 : menu_glyph_row = 16'h09F4;
            11'd167 : menu_glyph_row = 16'h0904;
            11'd168 : menu_glyph_row = 16'h0974;
            11'd169 : menu_glyph_row = 16'h0F14;
            11'd170 : menu_glyph_row = 16'h1A74;
            11'd171 : menu_glyph_row = 16'h0204;
            11'd172 : menu_glyph_row = 16'h061C;
            11'd178 : menu_glyph_row = 16'h0820;
            11'd179 : menu_glyph_row = 16'h08FC;
            11'd180 : menu_glyph_row = 16'h2820;
            11'd181 : menu_glyph_row = 16'h3E20;
            11'd182 : menu_glyph_row = 16'h29FC;
            11'd183 : menu_glyph_row = 16'h0808;
            11'd184 : menu_glyph_row = 16'h0E18;
            11'd185 : menu_glyph_row = 16'h38FC;
            11'd186 : menu_glyph_row = 16'h2808;
            11'd187 : menu_glyph_row = 16'h0888;
            11'd188 : menu_glyph_row = 16'h0808;
            11'd189 : menu_glyph_row = 16'h0830;
            11'd194 : menu_glyph_row = 16'h0820;
            11'd195 : menu_glyph_row = 16'h0060;
            11'd196 : menu_glyph_row = 16'h3F7C;
            11'd197 : menu_glyph_row = 16'h1248;
            11'd198 : menu_glyph_row = 16'h12C8;
            11'd199 : menu_glyph_row = 16'h2148;
            11'd200 : menu_glyph_row = 16'h1258;
            11'd201 : menu_glyph_row = 16'h0C30;
            11'd202 : menu_glyph_row = 16'h0C30;
            11'd203 : menu_glyph_row = 16'h0A30;
            11'd204 : menu_glyph_row = 16'h3058;
            11'd205 : menu_glyph_row = 16'h218C;
            11'd209 : menu_glyph_row = 16'h3DF8;
            11'd210 : menu_glyph_row = 16'h0508;
            11'd211 : menu_glyph_row = 16'h0588;
            11'd212 : menu_glyph_row = 16'h3C60;
            11'd213 : menu_glyph_row = 16'h2060;
            11'd214 : menu_glyph_row = 16'h21FC;
            11'd215 : menu_glyph_row = 16'h3D2C;
            11'd216 : menu_glyph_row = 16'h056C;
            11'd217 : menu_glyph_row = 16'h0560;
            11'd218 : menu_glyph_row = 16'h0428;
            11'd219 : menu_glyph_row = 16'h087C;
            11'd220 : menu_glyph_row = 16'h1B84;
            11'd226 : menu_glyph_row = 16'h0100;
            11'd227 : menu_glyph_row = 16'h1FF8;
            11'd228 : menu_glyph_row = 16'h0420;
            11'd229 : menu_glyph_row = 16'h0420;
            11'd230 : menu_glyph_row = 16'h3FFC;
            11'd232 : menu_glyph_row = 16'h0FF0;
            11'd233 : menu_glyph_row = 16'h0810;
            11'd234 : menu_glyph_row = 16'h0810;
            11'd235 : menu_glyph_row = 16'h0810;
            11'd236 : menu_glyph_row = 16'h0810;
            11'd237 : menu_glyph_row = 16'h0FF0;
            11'd242 : menu_glyph_row = 16'h04FC;
            11'd243 : menu_glyph_row = 16'h1420;
            11'd244 : menu_glyph_row = 16'h1620;
            11'd245 : menu_glyph_row = 16'h14FC;
            11'd246 : menu_glyph_row = 16'h3F84;
            11'd247 : menu_glyph_row = 16'h0094;
            11'd248 : menu_glyph_row = 16'h1594;
            11'd249 : menu_glyph_row = 16'h2694;
            11'd250 : menu_glyph_row = 16'h26A4;
            11'd251 : menu_glyph_row = 16'h0420;
            11'd252 : menu_glyph_row = 16'h1848;
            11'd253 : menu_glyph_row = 16'h3084;
            11'd258 : menu_glyph_row = 16'h0100;
            11'd259 : menu_glyph_row = 16'h1FFC;
            11'd260 : menu_glyph_row = 16'h3004;
            11'd262 : menu_glyph_row = 16'h0FF0;
            11'd263 : menu_glyph_row = 16'h0060;
            11'd264 : menu_glyph_row = 16'h0080;
            11'd265 : menu_glyph_row = 16'h3FFC;
            11'd266 : menu_glyph_row = 16'h0080;
            11'd267 : menu_glyph_row = 16'h0080;
            11'd268 : menu_glyph_row = 16'h0080;
            11'd269 : menu_glyph_row = 16'h0380;
            11'd274 : menu_glyph_row = 16'h1080;
            11'd275 : menu_glyph_row = 16'h13F8;
            11'd276 : menu_glyph_row = 16'h1880;
            11'd277 : menu_glyph_row = 16'h3BFC;
            11'd278 : menu_glyph_row = 16'h1040;
            11'd279 : menu_glyph_row = 16'h19F8;
            11'd280 : menu_glyph_row = 16'h3C48;
            11'd281 : menu_glyph_row = 16'h31F8;
            11'd282 : menu_glyph_row = 16'h1048;
            11'd283 : menu_glyph_row = 16'h11F8;
            11'd284 : menu_glyph_row = 16'h1190;
            11'd285 : menu_glyph_row = 16'h130C;
            11'd290 : menu_glyph_row = 16'h1910;
            11'd291 : menu_glyph_row = 16'h1110;
            11'd292 : menu_glyph_row = 16'h1510;
            11'd293 : menu_glyph_row = 16'h2510;
            11'd294 : menu_glyph_row = 16'h3910;
            11'd295 : menu_glyph_row = 16'h0910;
            11'd296 : menu_glyph_row = 16'h1190;
            11'd297 : menu_glyph_row = 16'h3D78;
            11'd298 : menu_glyph_row = 16'h0128;
            11'd299 : menu_glyph_row = 16'h0E28;
            11'd300 : menu_glyph_row = 16'h3244;
            11'd301 : menu_glyph_row = 16'h06C4;
            11'd306 : menu_glyph_row = 16'h0100;
            11'd307 : menu_glyph_row = 16'h0300;
            11'd308 : menu_glyph_row = 16'h1FFC;
            11'd309 : menu_glyph_row = 16'h0200;
            11'd310 : menu_glyph_row = 16'h0200;
            11'd311 : menu_glyph_row = 16'h0400;
            11'd312 : menu_glyph_row = 16'h07F8;
            11'd313 : menu_glyph_row = 16'h08C0;
            11'd314 : menu_glyph_row = 16'h18C0;
            11'd315 : menu_glyph_row = 16'h30C0;
            11'd316 : menu_glyph_row = 16'h20C0;
            11'd317 : menu_glyph_row = 16'h0FFC;
            11'd322 : menu_glyph_row = 16'h13F8;
            11'd323 : menu_glyph_row = 16'h0B08;
            11'd324 : menu_glyph_row = 16'h03C8;
            11'd325 : menu_glyph_row = 16'h2368;
            11'd326 : menu_glyph_row = 16'h17FC;
            11'd327 : menu_glyph_row = 16'h0404;
            11'd328 : menu_glyph_row = 16'h0118;
            11'd329 : menu_glyph_row = 16'h11F0;
            11'd330 : menu_glyph_row = 16'h1110;
            11'd331 : menu_glyph_row = 16'h31F0;
            11'd332 : menu_glyph_row = 16'h2110;
            11'd333 : menu_glyph_row = 16'h0110;
            11'd338 : menu_glyph_row = 16'h0100;
            11'd339 : menu_glyph_row = 16'h0100;
            11'd340 : menu_glyph_row = 16'h3FFC;
            11'd341 : menu_glyph_row = 16'h0200;
            11'd342 : menu_glyph_row = 16'h0200;
            11'd343 : menu_glyph_row = 16'h0400;
            11'd344 : menu_glyph_row = 16'h0FF8;
            11'd345 : menu_glyph_row = 16'h0C18;
            11'd346 : menu_glyph_row = 16'h1C18;
            11'd347 : menu_glyph_row = 16'h2418;
            11'd348 : menu_glyph_row = 16'h07F8;
            11'd349 : menu_glyph_row = 16'h07F8;
            11'd354 : menu_glyph_row = 16'h0600;
            11'd355 : menu_glyph_row = 16'h07E0;
            11'd356 : menu_glyph_row = 16'h0860;
            11'd357 : menu_glyph_row = 16'h3FF8;
            11'd358 : menu_glyph_row = 16'h0888;
            11'd359 : menu_glyph_row = 16'h0888;
            11'd360 : menu_glyph_row = 16'h0FF8;
            11'd361 : menu_glyph_row = 16'h0888;
            11'd362 : menu_glyph_row = 16'h0FF8;
            11'd363 : menu_glyph_row = 16'h1088;
            11'd364 : menu_glyph_row = 16'h1088;
            11'd365 : menu_glyph_row = 16'h2098;
            11'd369 : menu_glyph_row = 16'h1FF8;
            11'd370 : menu_glyph_row = 16'h0220;
            11'd371 : menu_glyph_row = 16'h0220;
            11'd372 : menu_glyph_row = 16'h0220;
            11'd373 : menu_glyph_row = 16'h0220;
            11'd374 : menu_glyph_row = 16'h3FFC;
            11'd375 : menu_glyph_row = 16'h0220;
            11'd376 : menu_glyph_row = 16'h0620;
            11'd377 : menu_glyph_row = 16'h0420;
            11'd378 : menu_glyph_row = 16'h0C20;
            11'd379 : menu_glyph_row = 16'h1820;
            11'd380 : menu_glyph_row = 16'h1020;
            11'd386 : menu_glyph_row = 16'h0888;
            11'd387 : menu_glyph_row = 16'h09FC;
            11'd388 : menu_glyph_row = 16'h3888;
            11'd389 : menu_glyph_row = 16'h1888;
            11'd390 : menu_glyph_row = 16'h18F8;
            11'd391 : menu_glyph_row = 16'h1C88;
            11'd392 : menu_glyph_row = 16'h38F8;
            11'd393 : menu_glyph_row = 16'h2888;
            11'd394 : menu_glyph_row = 16'h0BFC;
            11'd395 : menu_glyph_row = 16'h0800;
            11'd396 : menu_glyph_row = 16'h0898;
            11'd397 : menu_glyph_row = 16'h0904;
            11'd402 : menu_glyph_row = 16'h0300;
            11'd403 : menu_glyph_row = 16'h0FF0;
            11'd404 : menu_glyph_row = 16'h0910;
            11'd405 : menu_glyph_row = 16'h0890;
            11'd406 : menu_glyph_row = 16'h3FFC;
            11'd407 : menu_glyph_row = 16'h0910;
            11'd408 : menu_glyph_row = 16'h18B0;
            11'd409 : menu_glyph_row = 16'h1020;
            11'd410 : menu_glyph_row = 16'h1FF8;
            11'd411 : menu_glyph_row = 16'h1248;
            11'd412 : menu_glyph_row = 16'h1248;
            11'd413 : menu_glyph_row = 16'h3FFC;
            11'd418 : menu_glyph_row = 16'h0890;
            11'd419 : menu_glyph_row = 16'h10D8;
            11'd420 : menu_glyph_row = 16'h3DFC;
            11'd421 : menu_glyph_row = 16'h2090;
            11'd422 : menu_glyph_row = 16'h1DFC;
            11'd423 : menu_glyph_row = 16'h0800;
            11'd424 : menu_glyph_row = 16'h3C00;
            11'd425 : menu_glyph_row = 16'h1988;
            11'd426 : menu_glyph_row = 16'h0988;
            11'd427 : menu_glyph_row = 16'h0D88;
            11'd428 : menu_glyph_row = 16'h1988;
            11'd429 : menu_glyph_row = 16'h11F8;
            11'd434 : menu_glyph_row = 16'h08F8;
            11'd435 : menu_glyph_row = 16'h1000;
            11'd436 : menu_glyph_row = 16'h3000;
            11'd437 : menu_glyph_row = 16'h2C00;
            11'd438 : menu_glyph_row = 16'h09FC;
            11'd439 : menu_glyph_row = 16'h1810;
            11'd440 : menu_glyph_row = 16'h3810;
            11'd441 : menu_glyph_row = 16'h2810;
            11'd442 : menu_glyph_row = 16'h0810;
            11'd443 : menu_glyph_row = 16'h0810;
            11'd444 : menu_glyph_row = 16'h0810;
            11'd445 : menu_glyph_row = 16'h0870;
            11'd450 : menu_glyph_row = 16'h0180;
            11'd451 : menu_glyph_row = 16'h0180;
            11'd452 : menu_glyph_row = 16'h0180;
            11'd453 : menu_glyph_row = 16'h0180;
            11'd454 : menu_glyph_row = 16'h0180;
            11'd455 : menu_glyph_row = 16'h3FFC;
            11'd456 : menu_glyph_row = 16'h0180;
            11'd457 : menu_glyph_row = 16'h0180;
            11'd458 : menu_glyph_row = 16'h0180;
            11'd459 : menu_glyph_row = 16'h0180;
            11'd460 : menu_glyph_row = 16'h0180;
            11'd461 : menu_glyph_row = 16'h0180;
            11'd466 : menu_glyph_row = 16'h09F8;
            11'd467 : menu_glyph_row = 16'h09F8;
            11'd468 : menu_glyph_row = 16'h0D08;
            11'd469 : menu_glyph_row = 16'h3DF8;
            11'd470 : menu_glyph_row = 16'h2BFC;
            11'd471 : menu_glyph_row = 16'h2A84;
            11'd472 : menu_glyph_row = 16'h0BFC;
            11'd473 : menu_glyph_row = 16'h0800;
            11'd474 : menu_glyph_row = 16'h0998;
            11'd475 : menu_glyph_row = 16'h08D0;
            11'd476 : menu_glyph_row = 16'h0870;
            11'd477 : menu_glyph_row = 16'h0B8C;
            11'd482 : menu_glyph_row = 16'h0180;
            11'd483 : menu_glyph_row = 16'h0180;
            11'd484 : menu_glyph_row = 16'h0180;
            11'd485 : menu_glyph_row = 16'h1188;
            11'd486 : menu_glyph_row = 16'h1188;
            11'd487 : menu_glyph_row = 16'h1188;
            11'd488 : menu_glyph_row = 16'h1188;
            11'd489 : menu_glyph_row = 16'h1FF8;
            11'd490 : menu_glyph_row = 16'h0180;
            11'd491 : menu_glyph_row = 16'h0180;
            11'd492 : menu_glyph_row = 16'h0180;
            11'd493 : menu_glyph_row = 16'h0180;
            11'd498 : menu_glyph_row = 16'h0840;
            11'd499 : menu_glyph_row = 16'h0840;
            11'd500 : menu_glyph_row = 16'h0DF8;
            11'd501 : menu_glyph_row = 16'h3C48;
            11'd502 : menu_glyph_row = 16'h2C48;
            11'd503 : menu_glyph_row = 16'h2848;
            11'd504 : menu_glyph_row = 16'h0BFC;
            11'd505 : menu_glyph_row = 16'h0860;
            11'd506 : menu_glyph_row = 16'h08A0;
            11'd507 : menu_glyph_row = 16'h0990;
            11'd508 : menu_glyph_row = 16'h0908;
            11'd509 : menu_glyph_row = 16'h0E04;
            11'd513 : menu_glyph_row = 16'h1FFC;
            11'd514 : menu_glyph_row = 16'h1080;
            11'd515 : menu_glyph_row = 16'h1080;
            11'd516 : menu_glyph_row = 16'h13F8;
            11'd517 : menu_glyph_row = 16'h1208;
            11'd518 : menu_glyph_row = 16'h13F8;
            11'd519 : menu_glyph_row = 16'h1208;
            11'd520 : menu_glyph_row = 16'h13F8;
            11'd521 : menu_glyph_row = 16'h1040;
            11'd522 : menu_glyph_row = 16'h1258;
            11'd523 : menu_glyph_row = 16'h344C;
            11'd524 : menu_glyph_row = 16'h20C0;
            11'd529 : menu_glyph_row = 16'h3FFC;
            11'd530 : menu_glyph_row = 16'h2104;
            11'd531 : menu_glyph_row = 16'h23E4;
            11'd532 : menu_glyph_row = 16'h2644;
            11'd533 : menu_glyph_row = 16'h27C4;
            11'd534 : menu_glyph_row = 16'h2184;
            11'd535 : menu_glyph_row = 16'h2674;
            11'd536 : menu_glyph_row = 16'h21C4;
            11'd537 : menu_glyph_row = 16'h2204;
            11'd538 : menu_glyph_row = 16'h21C4;
            11'd539 : menu_glyph_row = 16'h300C;
            11'd540 : menu_glyph_row = 16'h3FFC;
            11'd546 : menu_glyph_row = 16'h0200;
            11'd547 : menu_glyph_row = 16'h1FFC;
            11'd548 : menu_glyph_row = 16'h0600;
            11'd549 : menu_glyph_row = 16'h0440;
            11'd550 : menu_glyph_row = 16'h0440;
            11'd551 : menu_glyph_row = 16'h0A48;
            11'd552 : menu_glyph_row = 16'h0A58;
            11'd553 : menu_glyph_row = 16'h12D0;
            11'd554 : menu_glyph_row = 16'h30E0;
            11'd555 : menu_glyph_row = 16'h21B0;
            11'd556 : menu_glyph_row = 16'h0318;
            11'd557 : menu_glyph_row = 16'h0C04;
            11'd564 : menu_glyph_row = 16'h1FF8;
            11'd572 : menu_glyph_row = 16'h3FFC;
            11'd578 : menu_glyph_row = 16'h0C40;
            11'd579 : menu_glyph_row = 16'h0BFC;
            11'd580 : menu_glyph_row = 16'h1840;
            11'd581 : menu_glyph_row = 16'h19F8;
            11'd582 : menu_glyph_row = 16'h3908;
            11'd583 : menu_glyph_row = 16'h29F8;
            11'd584 : menu_glyph_row = 16'h0908;
            11'd585 : menu_glyph_row = 16'h09F8;
            11'd586 : menu_glyph_row = 16'h0908;
            11'd587 : menu_glyph_row = 16'h09F8;
            11'd588 : menu_glyph_row = 16'h0B08;
            11'd589 : menu_glyph_row = 16'h0BFC;
            11'd593 : menu_glyph_row = 16'h0038;
            11'd594 : menu_glyph_row = 16'h0FC0;
            11'd595 : menu_glyph_row = 16'h0800;
            11'd596 : menu_glyph_row = 16'h0800;
            11'd597 : menu_glyph_row = 16'h0FF0;
            11'd598 : menu_glyph_row = 16'h0A10;
            11'd599 : menu_glyph_row = 16'h1A30;
            11'd600 : menu_glyph_row = 16'h1120;
            11'd601 : menu_glyph_row = 16'h11E0;
            11'd602 : menu_glyph_row = 16'h10C0;
            11'd603 : menu_glyph_row = 16'h33F0;
            11'd604 : menu_glyph_row = 16'h2E1C;
            11'd610 : menu_glyph_row = 16'h0E00;
            11'd611 : menu_glyph_row = 16'h0A00;
            11'd612 : menu_glyph_row = 16'h1BBC;
            11'd613 : menu_glyph_row = 16'h1AA4;
            11'd614 : menu_glyph_row = 16'h3AA4;
            11'd615 : menu_glyph_row = 16'h2AA4;
            11'd616 : menu_glyph_row = 16'h0AA4;
            11'd617 : menu_glyph_row = 16'h0AA4;
            11'd618 : menu_glyph_row = 16'h0AA4;
            11'd619 : menu_glyph_row = 16'h0AA4;
            11'd620 : menu_glyph_row = 16'h0CBC;
            11'd621 : menu_glyph_row = 16'h0DA4;
            11'd625 : menu_glyph_row = 16'h1FE0;
            11'd626 : menu_glyph_row = 16'h0030;
            11'd627 : menu_glyph_row = 16'h0420;
            11'd628 : menu_glyph_row = 16'h0420;
            11'd629 : menu_glyph_row = 16'h0C20;
            11'd630 : menu_glyph_row = 16'h0C20;
            11'd631 : menu_glyph_row = 16'h07FC;
            11'd632 : menu_glyph_row = 16'h0008;
            11'd633 : menu_glyph_row = 16'h3FE8;
            11'd634 : menu_glyph_row = 16'h0008;
            11'd635 : menu_glyph_row = 16'h0008;
            11'd636 : menu_glyph_row = 16'h0078;
            11'd642 : menu_glyph_row = 16'h0420;
            11'd643 : menu_glyph_row = 16'h0260;
            11'd644 : menu_glyph_row = 16'h0240;
            11'd645 : menu_glyph_row = 16'h1FF8;
            11'd646 : menu_glyph_row = 16'h0100;
            11'd647 : menu_glyph_row = 16'h0100;
            11'd648 : menu_glyph_row = 16'h1FFC;
            11'd649 : menu_glyph_row = 16'h0180;
            11'd650 : menu_glyph_row = 16'h01C0;
            11'd651 : menu_glyph_row = 16'h0260;
            11'd652 : menu_glyph_row = 16'h0C38;
            11'd653 : menu_glyph_row = 16'h380C;
            11'd658 : menu_glyph_row = 16'h09FC;
            11'd659 : menu_glyph_row = 16'h0804;
            11'd660 : menu_glyph_row = 16'h0044;
            11'd661 : menu_glyph_row = 16'h20C4;
            11'd662 : menu_glyph_row = 16'h2FF4;
            11'd663 : menu_glyph_row = 16'h21C4;
            11'd664 : menu_glyph_row = 16'h21C4;
            11'd665 : menu_glyph_row = 16'h22C4;
            11'd666 : menu_glyph_row = 16'h26C4;
            11'd667 : menu_glyph_row = 16'h2CC4;
            11'd668 : menu_glyph_row = 16'h2184;
            11'd669 : menu_glyph_row = 16'h2018;
            11'd674 : menu_glyph_row = 16'h0040;
            11'd675 : menu_glyph_row = 16'h1860;
            11'd676 : menu_glyph_row = 16'h03FC;
            11'd677 : menu_glyph_row = 16'h2248;
            11'd678 : menu_glyph_row = 16'h3240;
            11'd679 : menu_glyph_row = 16'h03F8;
            11'd680 : menu_glyph_row = 16'h0288;
            11'd681 : menu_glyph_row = 16'h0A90;
            11'd682 : menu_glyph_row = 16'h1270;
            11'd683 : menu_glyph_row = 16'h3460;
            11'd684 : menu_glyph_row = 16'h24F0;
            11'd685 : menu_glyph_row = 16'h038C;
            11'd690 : menu_glyph_row = 16'h1F88;
            11'd691 : menu_glyph_row = 16'h0B18;
            11'd692 : menu_glyph_row = 16'h0A30;
            11'd693 : menu_glyph_row = 16'h0A60;
            11'd694 : menu_glyph_row = 16'h0A0C;
            11'd695 : menu_glyph_row = 16'h3F98;
            11'd696 : menu_glyph_row = 16'h0A30;
            11'd697 : menu_glyph_row = 16'h1260;
            11'd698 : menu_glyph_row = 16'h120C;
            11'd699 : menu_glyph_row = 16'h1218;
            11'd700 : menu_glyph_row = 16'h3230;
            11'd701 : menu_glyph_row = 16'h2040;
            11'd706 : menu_glyph_row = 16'h0190;
            11'd707 : menu_glyph_row = 16'h13FC;
            11'd708 : menu_glyph_row = 16'h00B0;
            11'd709 : menu_glyph_row = 16'h0298;
            11'd710 : menu_glyph_row = 16'h3098;
            11'd711 : menu_glyph_row = 16'h17FC;
            11'd712 : menu_glyph_row = 16'h1000;
            11'd713 : menu_glyph_row = 16'h11F8;
            11'd714 : menu_glyph_row = 16'h1108;
            11'd715 : menu_glyph_row = 16'h1DF8;
            11'd716 : menu_glyph_row = 16'h1908;
            11'd717 : menu_glyph_row = 16'h11F8;
            11'd722 : menu_glyph_row = 16'h09F8;
            11'd723 : menu_glyph_row = 16'h1008;
            11'd724 : menu_glyph_row = 16'h14F8;
            11'd725 : menu_glyph_row = 16'h2408;
            11'd726 : menu_glyph_row = 16'h3808;
            11'd727 : menu_glyph_row = 16'h0864;
            11'd728 : menu_glyph_row = 16'h1120;
            11'd729 : menu_glyph_row = 16'h3D38;
            11'd730 : menu_glyph_row = 16'h00F0;
            11'd731 : menu_glyph_row = 16'h01A8;
            11'd732 : menu_glyph_row = 16'h3B2C;
            11'd733 : menu_glyph_row = 16'h0060;
            11'd738 : menu_glyph_row = 16'h0788;
            11'd739 : menu_glyph_row = 16'h3C18;
            11'd740 : menu_glyph_row = 16'h04B0;
            11'd741 : menu_glyph_row = 16'h15A0;
            11'd742 : menu_glyph_row = 16'h110C;
            11'd743 : menu_glyph_row = 16'h0418;
            11'd744 : menu_glyph_row = 16'h3FB0;
            11'd745 : menu_glyph_row = 16'h0C60;
            11'd746 : menu_glyph_row = 16'h0F0C;
            11'd747 : menu_glyph_row = 16'h1598;
            11'd748 : menu_glyph_row = 16'h3430;
            11'd749 : menu_glyph_row = 16'h2460;
            11'd754 : menu_glyph_row = 16'h0800;
            11'd755 : menu_glyph_row = 16'h08FC;
            11'd756 : menu_glyph_row = 16'h3E20;
            11'd757 : menu_glyph_row = 16'h2A20;
            11'd758 : menu_glyph_row = 16'h2A20;
            11'd759 : menu_glyph_row = 16'h2A20;
            11'd760 : menu_glyph_row = 16'h3E20;
            11'd761 : menu_glyph_row = 16'h2A20;
            11'd762 : menu_glyph_row = 16'h2820;
            11'd763 : menu_glyph_row = 16'h0A20;
            11'd764 : menu_glyph_row = 16'h1E30;
            11'd765 : menu_glyph_row = 16'h21FC;
            11'd770 : menu_glyph_row = 16'h0300;
            11'd771 : menu_glyph_row = 16'h0200;
            11'd772 : menu_glyph_row = 16'h1FF8;
            11'd773 : menu_glyph_row = 16'h1008;
            11'd774 : menu_glyph_row = 16'h1008;
            11'd775 : menu_glyph_row = 16'h1008;
            11'd776 : menu_glyph_row = 16'h1FF8;
            11'd777 : menu_glyph_row = 16'h1008;
            11'd778 : menu_glyph_row = 16'h1008;
            11'd779 : menu_glyph_row = 16'h1008;
            11'd780 : menu_glyph_row = 16'h1FF8;
            11'd781 : menu_glyph_row = 16'h1008;
            11'd786 : menu_glyph_row = 16'h0838;
            11'd787 : menu_glyph_row = 16'h3F40;
            11'd788 : menu_glyph_row = 16'h1440;
            11'd789 : menu_glyph_row = 16'h1F50;
            11'd790 : menu_glyph_row = 16'h0450;
            11'd791 : menu_glyph_row = 16'h3E90;
            11'd792 : menu_glyph_row = 16'h0010;
            11'd793 : menu_glyph_row = 16'h0FF0;
            11'd794 : menu_glyph_row = 16'h0810;
            11'd795 : menu_glyph_row = 16'h0FF0;
            11'd796 : menu_glyph_row = 16'h0810;
            11'd797 : menu_glyph_row = 16'h0FF0;
            11'd802 : menu_glyph_row = 16'h0860;
            11'd803 : menu_glyph_row = 16'h1BFC;
            11'd804 : menu_glyph_row = 16'h11F0;
            11'd805 : menu_glyph_row = 16'h3108;
            11'd806 : menu_glyph_row = 16'h31F8;
            11'd807 : menu_glyph_row = 16'h3000;
            11'd808 : menu_glyph_row = 16'h17FC;
            11'd809 : menu_glyph_row = 16'h1400;
            11'd810 : menu_glyph_row = 16'h11F8;
            11'd811 : menu_glyph_row = 16'h1040;
            11'd812 : menu_glyph_row = 16'h1040;
            11'd813 : menu_glyph_row = 16'h10C0;
            11'd818 : menu_glyph_row = 16'h04F8;
            11'd819 : menu_glyph_row = 16'h0C6C;
            11'd820 : menu_glyph_row = 16'h0C64;
            11'd821 : menu_glyph_row = 16'h0444;
            11'd822 : menu_glyph_row = 16'h3FD8;
            11'd823 : menu_glyph_row = 16'h0410;
            11'd824 : menu_glyph_row = 16'h147C;
            11'd825 : menu_glyph_row = 16'h1744;
            11'd826 : menu_glyph_row = 16'h3444;
            11'd827 : menu_glyph_row = 16'h3C7C;
            11'd828 : menu_glyph_row = 16'h2C00;
            11'd829 : menu_glyph_row = 16'h23FC;
            11'd834 : menu_glyph_row = 16'h0300;
            11'd835 : menu_glyph_row = 16'h06C0;
            11'd836 : menu_glyph_row = 16'h0440;
            11'd837 : menu_glyph_row = 16'h0440;
            11'd838 : menu_glyph_row = 16'h0C40;
            11'd839 : menu_glyph_row = 16'h0C40;
            11'd840 : menu_glyph_row = 16'h0440;
            11'd841 : menu_glyph_row = 16'h0440;
            11'd842 : menu_glyph_row = 16'h06C0;
            11'd843 : menu_glyph_row = 16'h0380;
            11'd851 : menu_glyph_row = 16'h0100;
            11'd852 : menu_glyph_row = 16'h0300;
            11'd853 : menu_glyph_row = 16'h0700;
            11'd854 : menu_glyph_row = 16'h0100;
            11'd855 : menu_glyph_row = 16'h0100;
            11'd856 : menu_glyph_row = 16'h0100;
            11'd857 : menu_glyph_row = 16'h0100;
            11'd858 : menu_glyph_row = 16'h0100;
            11'd859 : menu_glyph_row = 16'h0100;
            11'd860 : menu_glyph_row = 16'h0100;
            11'd867 : menu_glyph_row = 16'h0380;
            11'd868 : menu_glyph_row = 16'h06C0;
            11'd869 : menu_glyph_row = 16'h0440;
            11'd870 : menu_glyph_row = 16'h0040;
            11'd871 : menu_glyph_row = 16'h0080;
            11'd872 : menu_glyph_row = 16'h0080;
            11'd873 : menu_glyph_row = 16'h0100;
            11'd874 : menu_glyph_row = 16'h0200;
            11'd875 : menu_glyph_row = 16'h0600;
            11'd876 : menu_glyph_row = 16'h07C0;
            11'd883 : menu_glyph_row = 16'h0380;
            11'd884 : menu_glyph_row = 16'h06C0;
            11'd885 : menu_glyph_row = 16'h0440;
            11'd886 : menu_glyph_row = 16'h0040;
            11'd887 : menu_glyph_row = 16'h0180;
            11'd888 : menu_glyph_row = 16'h00C0;
            11'd889 : menu_glyph_row = 16'h0040;
            11'd890 : menu_glyph_row = 16'h0440;
            11'd891 : menu_glyph_row = 16'h06C0;
            11'd892 : menu_glyph_row = 16'h0380;
            11'd900 : menu_glyph_row = 16'h0080;
            11'd901 : menu_glyph_row = 16'h0180;
            11'd902 : menu_glyph_row = 16'h0380;
            11'd903 : menu_glyph_row = 16'h0280;
            11'd904 : menu_glyph_row = 16'h0480;
            11'd905 : menu_glyph_row = 16'h0CC0;
            11'd906 : menu_glyph_row = 16'h07C0;
            11'd907 : menu_glyph_row = 16'h0080;
            11'd915 : menu_glyph_row = 16'h0380;
            11'd916 : menu_glyph_row = 16'h0600;
            11'd917 : menu_glyph_row = 16'h0400;
            11'd918 : menu_glyph_row = 16'h0500;
            11'd919 : menu_glyph_row = 16'h06C0;
            11'd920 : menu_glyph_row = 16'h0040;
            11'd921 : menu_glyph_row = 16'h0040;
            11'd922 : menu_glyph_row = 16'h0840;
            11'd923 : menu_glyph_row = 16'h04C0;
            11'd924 : menu_glyph_row = 16'h0300;
            11'd931 : menu_glyph_row = 16'h0080;
            11'd932 : menu_glyph_row = 16'h0100;
            11'd933 : menu_glyph_row = 16'h0300;
            11'd934 : menu_glyph_row = 16'h0200;
            11'd935 : menu_glyph_row = 16'h07C0;
            11'd936 : menu_glyph_row = 16'h0440;
            11'd937 : menu_glyph_row = 16'h0460;
            11'd938 : menu_glyph_row = 16'h0460;
            11'd939 : menu_glyph_row = 16'h0640;
            11'd940 : menu_glyph_row = 16'h0380;
            11'd947 : menu_glyph_row = 16'h07C0;
            11'd948 : menu_glyph_row = 16'h0040;
            11'd949 : menu_glyph_row = 16'h0040;
            11'd950 : menu_glyph_row = 16'h0080;
            11'd951 : menu_glyph_row = 16'h0080;
            11'd952 : menu_glyph_row = 16'h0100;
            11'd953 : menu_glyph_row = 16'h0100;
            11'd954 : menu_glyph_row = 16'h0300;
            11'd955 : menu_glyph_row = 16'h0200;
            11'd956 : menu_glyph_row = 16'h0200;
            11'd963 : menu_glyph_row = 16'h0300;
            11'd964 : menu_glyph_row = 16'h04C0;
            11'd965 : menu_glyph_row = 16'h0440;
            11'd966 : menu_glyph_row = 16'h0440;
            11'd967 : menu_glyph_row = 16'h0780;
            11'd968 : menu_glyph_row = 16'h06C0;
            11'd969 : menu_glyph_row = 16'h0C40;
            11'd970 : menu_glyph_row = 16'h0C40;
            11'd971 : menu_glyph_row = 16'h04C0;
            11'd972 : menu_glyph_row = 16'h0380;
            11'd979 : menu_glyph_row = 16'h0300;
            11'd980 : menu_glyph_row = 16'h06C0;
            11'd981 : menu_glyph_row = 16'h0C40;
            11'd982 : menu_glyph_row = 16'h0840;
            11'd983 : menu_glyph_row = 16'h0C40;
            11'd984 : menu_glyph_row = 16'h0780;
            11'd985 : menu_glyph_row = 16'h0180;
            11'd986 : menu_glyph_row = 16'h0100;
            11'd987 : menu_glyph_row = 16'h0100;
            11'd988 : menu_glyph_row = 16'h0200;
            default: menu_glyph_row = 16'h0000;
        endcase
    end
endfunction

function [6:0] menu_label_gid;
    input [3:0] item;
    input [1:0] col;
    reg [6:0] g;
    begin
        g = 7'd0;
        case (item)
            4'd0 : case (col)
                2'd0: g = 7'd1;
                2'd1: g = 7'd2;
                2'd2: g = 7'd0;
                2'd3: g = 7'd0;
                default: g = 7'd0;
            endcase
            4'd1 : case (col)
                2'd0: g = 7'd3;
                2'd1: g = 7'd4;
                2'd2: g = 7'd0;
                2'd3: g = 7'd0;
                default: g = 7'd0;
            endcase
            4'd2 : case (col)
                2'd0: g = 7'd5;
                2'd1: g = 7'd4;
                2'd2: g = 7'd0;
                2'd3: g = 7'd0;
                default: g = 7'd0;
            endcase
            4'd3 : case (col)
                2'd0: g = 7'd6;
                2'd1: g = 7'd7;
                2'd2: g = 7'd0;
                2'd3: g = 7'd0;
                default: g = 7'd0;
            endcase
            4'd4 : case (col)
                2'd0: g = 7'd8;
                2'd1: g = 7'd9;
                2'd2: g = 7'd0;
                2'd3: g = 7'd0;
                default: g = 7'd0;
            endcase
            4'd5 : case (col)
                2'd0: g = 7'd8;
                2'd1: g = 7'd10;
                2'd2: g = 7'd0;
                2'd3: g = 7'd0;
                default: g = 7'd0;
            endcase
            4'd6 : case (col)
                2'd0: g = 7'd11;
                2'd1: g = 7'd12;
                2'd2: g = 7'd0;
                2'd3: g = 7'd0;
                default: g = 7'd0;
            endcase
            4'd7 : case (col)
                2'd0: g = 7'd13;
                2'd1: g = 7'd4;
                2'd2: g = 7'd0;
                2'd3: g = 7'd0;
                default: g = 7'd0;
            endcase
            4'd8 : case (col)
                2'd0: g = 7'd14;
                2'd1: g = 7'd15;
                2'd2: g = 7'd0;
                2'd3: g = 7'd0;
                default: g = 7'd0;
            endcase
            4'd9 : case (col)
                2'd0: g = 7'd14;
                2'd1: g = 7'd8;
                2'd2: g = 7'd0;
                2'd3: g = 7'd0;
                default: g = 7'd0;
            endcase
            4'd10: case (col)
                2'd0: g = 7'd16;
                2'd1: g = 7'd8;
                2'd2: g = 7'd0;
                2'd3: g = 7'd0;
                default: g = 7'd0;
            endcase
            4'd11: case (col)
                2'd0: g = 7'd16;
                2'd1: g = 7'd3;
                2'd2: g = 7'd0;
                2'd3: g = 7'd0;
                default: g = 7'd0;
            endcase
            4'd12: case (col)
                2'd0: g = 7'd16;
                2'd1: g = 7'd17;
                2'd2: g = 7'd0;
                2'd3: g = 7'd0;
                default: g = 7'd0;
            endcase
            4'd13: case (col)
                2'd0: g = 7'd16;
                2'd1: g = 7'd18;
                2'd2: g = 7'd0;
                2'd3: g = 7'd0;
                default: g = 7'd0;
            endcase
            default: g = 7'd0;
        endcase
        menu_label_gid = g;
    end
endfunction

function [6:0] menu_value_gid;
    input [3:0] item;
    input [8:0] val;
    input [1:0] col;
    reg [6:0] g;
    reg [3:0] dig;
    begin
        g = 7'd0;
        case (item)
            4'd0 : case (val)
                8'd0: case (col)
                    2'd0: g = 7'd19;
                    2'd1: g = 7'd20;
                    2'd2: g = 7'd0;
                    2'd3: g = 7'd0;
                    default: g = 7'd0;
                endcase
                8'd1: case (col)
                    2'd0: g = 7'd21;
                    2'd1: g = 7'd20;
                    2'd2: g = 7'd0;
                    2'd3: g = 7'd0;
                    default: g = 7'd0;
                endcase
                8'd2: case (col)
                    2'd0: g = 7'd6;
                    2'd1: g = 7'd22;
                    2'd2: g = 7'd0;
                    2'd3: g = 7'd0;
                    default: g = 7'd0;
                endcase
                8'd3: case (col)
                    2'd0: g = 7'd6;
                    2'd1: g = 7'd23;
                    2'd2: g = 7'd0;
                    2'd3: g = 7'd0;
                    default: g = 7'd0;
                endcase
                8'd4: case (col)
                    2'd0: g = 7'd24;
                    2'd1: g = 7'd25;
                    2'd2: g = 7'd0;
                    2'd3: g = 7'd0;
                    default: g = 7'd0;
                endcase
                8'd5: case (col)
                    2'd0: g = 7'd26;
                    2'd1: g = 7'd27;
                    2'd2: g = 7'd0;
                    2'd3: g = 7'd0;
                    default: g = 7'd0;
                endcase
                8'd6: case (col)
                    2'd0: g = 7'd28;
                    2'd1: g = 7'd16;
                    2'd2: g = 7'd0;
                    2'd3: g = 7'd0;
                    default: g = 7'd0;
                endcase
                default: g = 7'd0;
            endcase
            4'd1 : case (val)
                8'd0: case (col)
                    2'd0: g = 7'd29;
                    2'd1: g = 7'd0;
                    2'd2: g = 7'd0;
                    2'd3: g = 7'd0;
                    default: g = 7'd0;
                endcase
                8'd1: case (col)
                    2'd0: g = 7'd30;
                    2'd1: g = 7'd0;
                    2'd2: g = 7'd0;
                    2'd3: g = 7'd0;
                    default: g = 7'd0;
                endcase
                8'd2: case (col)
                    2'd0: g = 7'd31;
                    2'd1: g = 7'd0;
                    2'd2: g = 7'd0;
                    2'd3: g = 7'd0;
                    default: g = 7'd0;
                endcase
                default: g = 7'd0;
            endcase
            4'd6 : case (val)
                8'd0: case (col)
                    2'd0: g = 7'd32;
                    2'd1: g = 7'd33;
                    2'd2: g = 7'd0;
                    2'd3: g = 7'd0;
                    default: g = 7'd0;
                endcase
                8'd1: case (col)
                    2'd0: g = 7'd34;
                    2'd1: g = 7'd4;
                    2'd2: g = 7'd0;
                    2'd3: g = 7'd0;
                    default: g = 7'd0;
                endcase
                8'd2: case (col)
                    2'd0: g = 7'd35;
                    2'd1: g = 7'd36;
                    2'd2: g = 7'd0;
                    2'd3: g = 7'd0;
                    default: g = 7'd0;
                endcase
                8'd3: case (col)
                    2'd0: g = 7'd37;
                    2'd1: g = 7'd8;
                    2'd2: g = 7'd0;
                    2'd3: g = 7'd0;
                    default: g = 7'd0;
                endcase
                8'd4: case (col)
                    2'd0: g = 7'd38;
                    2'd1: g = 7'd39;
                    2'd2: g = 7'd0;
                    2'd3: g = 7'd0;
                    default: g = 7'd0;
                endcase
                default: g = 7'd0;
            endcase
            4'd8 : case (val)
                8'd0: case (col)
                    2'd0: g = 7'd40;
                    2'd1: g = 7'd41;
                    2'd2: g = 7'd0;
                    2'd3: g = 7'd0;
                    default: g = 7'd0;
                endcase
                8'd1: case (col)
                    2'd0: g = 7'd42;
                    2'd1: g = 7'd43;
                    2'd2: g = 7'd0;
                    2'd3: g = 7'd0;
                    default: g = 7'd0;
                endcase
                8'd2: case (col)
                    2'd0: g = 7'd15;
                    2'd1: g = 7'd44;
                    2'd2: g = 7'd0;
                    2'd3: g = 7'd0;
                    default: g = 7'd0;
                endcase
                default: g = 7'd0;
            endcase
            4'd9 : case (val)
                8'd0: case (col)
                    2'd0: g = 7'd45;
                    2'd1: g = 7'd8;
                    2'd2: g = 7'd0;
                    2'd3: g = 7'd0;
                    default: g = 7'd0;
                endcase
                8'd1: case (col)
                    2'd0: g = 7'd46;
                    2'd1: g = 7'd47;
                    2'd2: g = 7'd0;
                    2'd3: g = 7'd0;
                    default: g = 7'd0;
                endcase
                default: g = 7'd0;
            endcase
            4'd10: case (val)
                8'd0: case (col)
                    2'd0: g = 7'd48;
                    2'd1: g = 7'd8;
                    2'd2: g = 7'd0;
                    2'd3: g = 7'd0;
                    default: g = 7'd0;
                endcase
                8'd1: case (col)
                    2'd0: g = 7'd46;
                    2'd1: g = 7'd47;
                    2'd2: g = 7'd0;
                    2'd3: g = 7'd0;
                    default: g = 7'd0;
                endcase
                default: g = 7'd0;
            endcase
            4'd11: case (val)
                8'd0: case (col)
                    2'd0: g = 7'd49;
                    2'd1: g = 7'd50;
                    2'd2: g = 7'd0;
                    2'd3: g = 7'd0;
                    default: g = 7'd0;
                endcase
                8'd1: case (col)
                    2'd0: g = 7'd31;
                    2'd1: g = 7'd3;
                    2'd2: g = 7'd0;
                    2'd3: g = 7'd0;
                    default: g = 7'd0;
                endcase
                8'd2: case (col)
                    2'd0: g = 7'd51;
                    2'd1: g = 7'd31;
                    2'd2: g = 7'd3;
                    2'd3: g = 7'd0;
                    default: g = 7'd0;
                endcase
                default: g = 7'd0;
            endcase
            default: begin
                case (col)
                    2'd0: dig = val / 8'd100;
                    2'd1: dig = (val / 8'd10) % 8'd10;
                    2'd2: dig = val % 8'd10;
                    default: dig = 4'd15;
                endcase
                case (dig)
                    4'd0: g = 7'd52;
                    4'd1: g = 7'd53;
                    4'd2: g = 7'd54;
                    4'd3: g = 7'd55;
                    4'd4: g = 7'd56;
                    4'd5: g = 7'd57;
                    4'd6: g = 7'd58;
                    4'd7: g = 7'd59;
                    4'd8: g = 7'd60;
                    4'd9: g = 7'd61;
                    default: g = 7'd0;
                endcase
            end
        endcase
        menu_value_gid = g;
    end
endfunction
