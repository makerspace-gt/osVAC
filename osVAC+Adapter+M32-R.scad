// diameter at the middle of adapter
d1 = 42.5;
// diameter at the end of adapter
d2 = 40.1;
// length of the adapter
length = 30.5;

/* [Hidden] */
nominal_diameter = 32.0;
fitting_length = 30.0;
wall_thickness = 3.0;

nameplate_diameter = 50.0;
nameplate_length = 17.0;
text_front = str("M32-R", d1, "/", d2, "x", length);
text_back = "ossso.de";
text_heigth = 6.5;
text_font = "Liberation Mono:style=Bold";
text_width = text_heigth * 0.82; // ~measured

nose_thickness = 2.0;
nose_width = 10.0;
nose_length = 7.0;
nose_offset = 3.2;

tolerance = 0.2;
radii = 1.0;
chamfer = 1;
overhang = 60.0;

$fn = 60;

x0 = nominal_diameter / 2;
x1 = x0 + wall_thickness - tolerance / 2;
x2 = x1;
x3 = nameplate_diameter / 2;
x4 = x3;
x5 = d2 > d1 ? d2 / 2 + wall_thickness : d1 / 2;
x6 = x5;
x7 = d2 > d1 ? x5 : d2 / 2;
x8 = d2 / 2 - (d2 <= d1 ? wall_thickness : 0);
x9t = d1 / 2 - (d2 <= d1 ? wall_thickness : 0);
x9 = d2 <= d1 && x9t > x0 ? x0 : x9t;
x10 = x0;

y0 = 0;
y1 = y0;
y2 = y0 + fitting_length + tolerance;
y3 = y2 + (x3 - x2) / tan(overhang);
y4 = y0 + fitting_length + nameplate_length;
y5 = x5 > x4 ? (y4 + (x5 - x4) / tan(overhang)) : y4;
y6 = x5 > x4 ? (y5 + wall_thickness / tan(overhang)) : y5;
y7 = y6 + length;
y8 = y7;
y9 = y6;
y10 = y9 - abs((x9 - x10) / tan(overhang));

adapter();

module
adapter()
{
    difference()
    {
        profile();

        nameplate(text = text_front);
        nameplate(text = text_back, eastwest = 180);
    }

    for (i = [1:3])
        rotate([ 0, 0, i * 120 ]) nose();
}

module
profile()
{
    points = [[x0, y0],
              [x1, y1],
              [x2, y2],
              [x3, y3],
              [x4, y4],
              [x5, y5],
              [x6, y6],
              [x7, y7],
              [x8, y8],
              [x9, y9],
              [x10, y10]];

    rotate_extrude() c_polygon(points = points, chamfer = chamfer);
}

module
nose()
{
    dy = nose_thickness / tan(overhang);

    nx0 = x0;
    nx1 = x1;
    nx2 = nx1 + nose_thickness;
    nx3 = nx2;
    nx4 = nx1;
    nx5 = nx0;

    ny0 = nose_offset;
    ny1 = ny0;
    ny2 = ny1 + dy;

    ny5 = ny0 + nose_length;
    ny4 = ny5;
    ny3 = ny4 - dy;

    points = [[nx0, ny0],
              [nx1, ny1],
              [nx2, ny2],
              [nx3, ny3],
              [nx4, ny4],
              [nx5, ny5]];

    intersection()
    {

        rotate_extrude(angle = 180)
            c_polygon(points = points, chamfer = chamfer);

        translate([ 0, nx2 / 2 ]) linear_extrude(ny5)
            square([ nose_width, nx2 ], center = true);
    }
}

module
c_polygon(points = [], chamfer = 1)
{
    extended_points = [ for (i = points) i, points[0], points[1] ];

    difference()
    {

        polygon(points = points);

        for (i = [1:len(points)]) {
            v01 = extended_points[i] - extended_points[i - 1];
            v12 = extended_points[i + 1] - extended_points[i];
            l01 = sqrt(v01[0] ^ 2 + v01[1] ^ 2);
            l12 = sqrt(v12[0] ^ 2 + v12[1] ^ 2);

            if (l01 >= chamfer * 2 && l12 >= chamfer * 2) {
                atan01 = 90 - atan2(v01[0], v01[1]);
                d01 = atan01 < 0 ? 360 + atan01 : atan01;

                atan12 = 90 - atan2(v12[0], v12[1]);
                d12 = atan12 <= 0 ? 360 + atan12 : atan12;

                angle = (d12 - d01) / 2;

                if (angle > 0 && d01 + angle > 30) {
                    translate(extended_points[i]) rotate(d01 + angle) square(
                        chamfer * [ cos(angle), sin(angle) ], center = true);
                }
            }
        }
    }
}

module
nameplate(text = "", eastwest = 0)
{
    //  inspired by
    //  https://www.openscad.info/index.php/2020/07/02/cylindrical-text-the-easy-way/
    RADIUS = x3;
    chars = len(text);
    ARC_ANGLE = 180 * chars * text_width / RADIUS / PI;

    for (i = [0:1:chars]) {
        rotate([ 0, 0, eastwest + i * ARC_ANGLE / chars - ARC_ANGLE / 2 ])
        {
            translate([ RADIUS - 1, 0, (y3 + y4 - text_heigth) / 2 ])
                rotate([ 90, 0, 90 ]) linear_extrude(1) text(text[i],
                                                             size = text_heigth,
                                                             halign = "center",
                                                             font = text_font);
        }
    }}