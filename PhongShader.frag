#version 450

uniform vec3 cameraPosition;
uniform mat4 MVP;//recuperation de la matrice mvp
uniform mat4 MODEL;
uniform float silhouette;
uniform float shadtype;
uniform float materialShininess;
uniform vec3 materialSpecularColor;
in vec3 fragPosition;
in vec3 fragNormale;
in mat3 jacobienne;
out vec4 finalColor;
in vec4 color;
vec4 ambient;
vec4 DIFFUSE ;
vec4 speculaire;
float eps=0.1;
uniform struct Light {vec3 position ;
                      vec3 intensities;
                    float ambientCoefficient;
                    float attenuation ;} light;


vec4 fcolor;

void main() 
{
    
    ambient=vec4(light.intensities,1.0)*light.ambientCoefficient;

    vec3 LIGHT_DIRECTION= normalize(light.position-fragPosition); 
    vec3 normale = normalize(transpose(inverse(mat3(MODEL)*jacobienne))*fragNormale);
    
    // diffuse parameters
    float diffcoef = max(dot(normale, LIGHT_DIRECTION), 0.0);
    vec3 DV= normalize(cameraPosition-fragPosition);
    
    // for silhouette checking
    float VDCOEFF=max(dot(normale, DV), 0.0);

    // specular parameters
    vec3 reflectDir = reflect(-LIGHT_DIRECTION, normale);
    float spec_term = pow(max(dot(reflectDir, DV), 0.0), materialShininess) ;
    vec4 specular =vec4( spec_term*materialSpecularColor,1.0);

  
    
   if(shadtype==1.0)
   { //toon
  if(diffcoef<0.15)
        DIFFUSE =vec4(0.13, 0.22, 0.22,1.0); 
        else
          if(diffcoef<0.25)
            DIFFUSE =vec4(0.33, 0.22, 0.22,1.0);
            else
            if(diffcoef<0.50)
                DIFFUSE =vec4(0.43, 0.22, 0.22,1.0);
                else
            if(diffcoef<0.70)
                DIFFUSE =vec4(0.68, 0.22, 0.22,1.0);
                else
                if(diffcoef<0.85)
                  DIFFUSE =vec4(0.73, 0.22, 0.22,1.0);
                    else
                    DIFFUSE =vec4(light.intensities,1.0);

   fcolor = ambient+DIFFUSE+specular;
   }
   else
   { // gooch
   float DiffCool = 0.3;
   float DiffWarm = 0.1;
   vec3 CoolColor = vec3(0, 0, 0.6);
   vec3 WarmColor = vec3(0.6, 0.6, 0);  

   vec3 kcool = min(CoolColor + DiffCool * light.intensities, 1.0);
   vec3 kwarm = min(WarmColor + DiffWarm * light.intensities, 1.0);
   float NdotL=(dot(LIGHT_DIRECTION,normale)+1)*0.5;
   vec3 kfinal = mix(kcool, kwarm, NdotL);
   vec4 gooch = vec4(min(kfinal + spec_term, 1.0), 1.0);
   fcolor = gooch;
    


   }
    


    if(silhouette==1.0&&VDCOEFF<0.2)
    finalColor=vec4(0,0,0,0);
    else
    finalColor=fcolor;


}

