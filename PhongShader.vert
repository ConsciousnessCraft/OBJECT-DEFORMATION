#version 450
#define PI 3.1415926538

uniform mat4 MVP;//recuperation de la matrice mvp
uniform mat4 MODEL;
uniform float deformation;
layout(location = 0) in vec3 position; // le location permet de dire de quel flux/canal on récupère les données (doit être en accord avec le location du code opengl)
layout (location =3) in vec3 normale;//recuperation des normale
out vec4 color ;
out vec3 fragPosition;
out vec3 fragNormale;
out mat3 jacobienne;
mat3 temporary_jacobienne;
uniform float thetamx;
uniform float tmin;
uniform float tmax;
 

//uniform deformation=0.0  pincement 
//uniform deformation=1.0  twist 
//uniform deformation=3.0  vortex



float my_Pincement(float x, float tmin, float tmax) {
    if (x < tmin)
        return 1.0;
    else if (x > tmax)
        return 0.5;
    else
        return 1.0 - 0.5 * ((x - tmin) / (tmax - tmin));
}

float my_Twist(float x, float tmin, float tmax, float tethamax) {
    if (x < tmin)
        return 0.0;
    else if (x > tmax)
        return tethamax;
    else
        return tethamax * ((x - tmin) / (tmax - tmin));
}



void main()
{ 
  mat3 temporary_jacobienne = mat3(0.0); 

  float tethamax=thetamx*PI;
  
  if(deformation==0.0)
  {   
      float def_results=my_Pincement(position.x,tmin,tmax);
      temporary_jacobienne=  mat3(
                            1, 0, 0, 
                            0, def_results, 0, 
                            0, 0,def_results
                        );
      if( position.x<tmin||position.x>tmax)
      jacobienne=temporary_jacobienne;
      else
      jacobienne= mat3(    1, 0, 0, 
                        (-position.y)/(2*(tmax-tmin)), def_results,  0,
                        (-position.z)/(2*(tmax-tmin)),  0,  def_results
                    );
                    
  }
  
  else

      if(deformation==1.0)
      {
        float def_results=my_Twist(position.x,tmin,tmax,tethamax);
        temporary_jacobienne=  mat3(
                    1,0,0,
                    0 ,  cos(def_results), -sin(def_results),
                    0,  sin(def_results), cos(def_results)  
                    );   
         if( position.x<tmin||position.x>tmax)
          jacobienne=temporary_jacobienne;
          else
          
          jacobienne= mat3( 1, 0, 0, 
                            (tethamax/(tmax-tmin))*(((position.y)*sin(def_results))+((position.z)*cos(def_results))),cos(def_results) ,-sin(def_results),
                            (tethamax/(tmax-tmin))*(((position.y)*cos(def_results))-((position.z)*sin(def_results))),sin(def_results) ,cos(def_results)
                        );
      } 
      else                
         if(deformation==3.0)   
          {   
            float coef=exp(-(position.z*position.z+position.y*position.y));
            float def_results=my_Twist(position.x,tmin,tmax,tethamax);
            temporary_jacobienne=  mat3(

                        1,0,0,
                        0 ,  cos(def_results*coef), -sin(def_results*coef),
                        0,  sin(def_results*coef), cos(def_results*coef)
                        
                        );  

            if( position.x<tmin||position.x>tmax)
              jacobienne=temporary_jacobienne;
              else
              jacobienne= mat3( 1, 0, 0, 
                              (tethamax/(tmax-tmin))*(((position.y)*sin(def_results*coef))+((position.z)*cos(def_results*coef))),cos(def_results*coef) ,-sin(def_results*coef),
                              (tethamax/(tmax-tmin))*(((position.y)*cos(def_results*coef))-((position.z)*sin(def_results*coef))),sin(def_results*coef) ,cos(def_results*coef)
                            );
          }

      // for the normal
      color=vec4(position,1.0);
      gl_Position= MVP* vec4((temporary_jacobienne*position),1.0);
      fragPosition =vec3(MODEL* vec4((temporary_jacobienne*position),1.0));
      fragNormale =normale;
  }




