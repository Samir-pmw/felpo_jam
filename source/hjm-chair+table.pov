//
// PovRay scene file for a simple wooden chair and table
//
// Author:   Hj. Malthaner
// Email:    hansjoerg.malthaner@gmx.de
// Creation:  08-Jun-03
// Update:    08-Dec-09
//
// Web:      http://opengameart.org/users/varkalandar
//
// This file is available under the GNU general
// public license v2 or newer.
//
// http://www.gnu.org/licenses/gpl-2.0.html
//
  
#declare Cam1 = camera {
	orthographic
	location < 2.5, 2.5*0.82, 2.5 >*1.4
	look_at < 0, 0, 0 >
}

camera { 
	Cam1 
}

light_source { 
	< 2.5*20, 100, 2.5*10 >
	color rgb < 1, 1, 1 > 
}

// sky sphere

sphere {
	<0,0,0>, 10000

	hollow

	pigment {
		color rgb 1
	}
}	


#declare FLOOR = 
plane 
{
  <0, 1, 0>, 0

  texture 
  {
		pigment 
    {
      color rgb 0.3
			quick_color rgb 1
		}

		normal 
    {
			bumps 0.1
			scale 0.5                
		}

		finish 
    {
			ambient 0.2
		}
	}
}


#declare TEX_WOOD = texture {

	pigment {
        	wood

	        color_map { 
        		[0.1 color rgb <0.60, 0.35, 0.20>]
        		[0.9 color rgb <0.90, 0.65, 0.30>]
                        [1.0 color rgb <0.60, 0.35, 0.20>]
                }
        	turbulence <0.06, 0.1, 1000>
        	scale <0.03, 0.03, 0.1>
        	rotate <1, 1, 0>
	}

	normal {
		bumps 0.4
		scale 0.4
	}
}


#declare CHAIRFOOT = box {

	<-0.15, 0, -0.15> 
	<0.15, 1.0, 0.15>

	texture {
		TEX_WOOD

		rotate <90, 0, 0>
	}
}

#declare FEET_THICK = 0.8;


#declare CHAIR = union {


	// Seat
	box {
		<-1, 1.7, -1>
		<1, 1.9, 1>

		texture {
			TEX_WOOD
		}
	}


	box {
		<-0.8, 1.1, 0.8>
		<0.8, 1.3, 0.9>

		texture {
			TEX_WOOD
			rotate <0, 90, 0>
		}
	}


	box {
		<-0.8, 1.1, -0.9>
		<0.8, 1.3, -0.8>

		texture {
			TEX_WOOD
			rotate <0, 90, 0>
		}
	}

	object {
		CHAIRFOOT
		scale <FEET_THICK, 1.7, FEET_THICK>
		translate <1-0.15, 0, 1-0.15>
	}

	object {
		CHAIRFOOT
		scale <FEET_THICK, 1.7, FEET_THICK>
		translate <1-0.15, 0, -1+0.15>
	}


	object {
		CHAIRFOOT
		scale <FEET_THICK, 1.7, FEET_THICK>
		translate <-1+0.15, 0, 1-0.15>
	}

	object {
		CHAIRFOOT
		scale <FEET_THICK, 1.7, FEET_THICK>
		translate <-1+0.15, 0, -1+0.15>
	}


	// Back

	box {
		<-1.0, 1.7, 0.9> 
		<-0.8, 4, -0.9>


		texture {
			TEX_WOOD
			rotate <90, 0, 0>
		}
		
                rotate <0, 0, 7>
                translate <0.4, 0.1, 0>
	}


	// Arm rests

	box {
		<-1, 2.5, 0.7>
		<1, 2.7, 1>

		texture {
			TEX_WOOD
			rotate <0, 90, 0>
		}
	}


	box {
		<-1, 2.5, -1>
		<1, 2.7, -0.7>

		texture {
			TEX_WOOD
			rotate <0, 90, 0>
		}
	}

        
        // Supports
        
	object {
		CHAIRFOOT
		scale <0.5, 0.6, 0.5>
		translate <1-0.15, 1.9, 1-0.15>
	}

	object {
		CHAIRFOOT
		scale <0.5, 0.6, 0.5>
		translate <1-0.15, 1.9, -1+0.15>
	}
  
  scale <1, 1, 1.2>
}

#declare TABLE_LEG = box {

	<-0.15, 0, -0.15> 
	<0.15, 1.0, 0.15>

	texture {
		TEX_WOOD

		rotate <90, 0, 0>
	}
}

#declare LEG_THICKNESS = 0.4;
#declare LEG_OFFSET = 0.8;

#declare TABLE = union {


	// Table top
	cone {
		<0, 1.7, 0>, 1.3
		<0, 1.8, 0>, 1.3

		texture {
			TEX_WOOD
		}
	}


	box {
		<-LEG_OFFSET, 1.3, LEG_OFFSET-0.1>
		<LEG_OFFSET, 1.7, LEG_OFFSET-0.2>

		texture {
			TEX_WOOD
			rotate <0, 90, 0>
		}
	}


	box {
		<-LEG_OFFSET, 1.3, -LEG_OFFSET+0.1>
		<LEG_OFFSET, 1.7, -LEG_OFFSET+0.2>

		texture {
			TEX_WOOD
			rotate <0, 90, 0>
		}
	}


	box {
		<LEG_OFFSET-0.2, 1.3, -LEG_OFFSET>
		<LEG_OFFSET-0.1, 1.7, LEG_OFFSET>

	}

        
   // Legs
        
	object {
		TABLE_LEG
		scale <LEG_THICKNESS, 1.7, LEG_THICKNESS>
		translate <LEG_OFFSET-0.15, 0, LEG_OFFSET-0.15>
	}

	object {
		TABLE_LEG
		scale <LEG_THICKNESS, 1.7, LEG_THICKNESS>
		translate <LEG_OFFSET-0.15, 0, -LEG_OFFSET+0.15>
	}


	object {
		TABLE_LEG
		scale <LEG_THICKNESS, 1.7, LEG_THICKNESS>
		translate <-LEG_OFFSET+0.15, 0, LEG_OFFSET-0.15>
	}

	object {
		TABLE_LEG
		scale <LEG_THICKNESS, 1.7, LEG_THICKNESS>
		translate <-LEG_OFFSET+0.15, 0, -LEG_OFFSET+0.15>
	}
}


union 
{
	object 
  {
		FLOOR
	}

	object 
  {
		TABLE
		scale 0.8
	}

  object 
  {
		CHAIR
		scale 0.4
    
    translate <-3, 0, 0>
    rotate <0, 0, 0>
	}

  object 
  {
		CHAIR
		scale 0.4
    
    translate <-3, 0, 0>
    rotate <0, 90, 0>
	}

  object 
  {
		CHAIR
		scale 0.4
    
    translate <-3, 0, 0>
    rotate <0, 180, 0>
	}

  object 
  {
		CHAIR
		scale 0.4
    
    translate <-3, 0, 0>
    rotate <0, 270, 0>
	}

  scale 0.8
	translate <0, -1, 0>
}
