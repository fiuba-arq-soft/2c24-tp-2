# Punto de partida para el TP 2 de Arquitectura de Software (75.73/TB054) del 2do cuatrimestre de 2024

> La fecha de entrega para el informe y el código será el __*jueves 28/11 a las 17:59hs*__.
> La misma herramienta de GitHub Classroom nos va a mostrar el último commit que hayan hecho sobre `main` hasta ese momento, con lo que es un deadline fijo y estricto. :warning: :bangbang:

## Contexto

Para este Trabajo, implementaremos sobre Azure un servicio similar al que realizamos en el TP 1. Será una app hecha en Node que consumirá las mismas APIs del TP 1, y agregará un GUID a cada respuesta. Este GUID será provisto por un servicio que se ejecutará en un container, también deployado en la nube.

Creando una sola instancia de la app en Node, deben ejecutar corridas que muestren el comportamiento de la aplicación, recolectando métricas (propias como en el TP 1 y tomadas automáticamente) que serán enviadas a Datadog. Luego, deberán escalar a 3 instancias y ejecutar nuevamente.

Cuando hayan finalizado el paso anterior, deben repetir introduciendo cache con Redis utilizando el servicio apropiado de Azure. No es necesario probar Redis con ambas configuraciones de la app Node (sin escalar y escalando horizontalmente), basta con que lo usen en *una* configuración y aclaren de cuál se trata.

En cada caso, deberán analizar y explicar qué está ocurriendo según lo que visualizan. Si encuentran algún cuello de botella o limitación, deben proponer y probar alguna táctica superadora, siempre que tenga sentido dentro del caso analizado.

Tanto para escalar horizontalmente como para agregar una instancia de Redis, cada grupo deberá modificar/agregar archivos de Terraform como sea necesario.

- Para escalar en un Virtual Machine Scaling Set (VMSS), ajustar el parámetro *instances* según lo deseado.
- Para crear una instancia de Redis en Azure, mirar el [recurso azurerm_redis_cache de Terraform](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/redis_cache).

Para la administración de las instancias del VMSS se utilizará un [jumpbox](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/cloud-scale-analytics/architectures/connect-to-environments-privately)

## Setup

### Archivo de variables

- Crear dentro de este repository un archivo `terraform.tfvars`:

    > __ATENCIÓN: EVITEN COMMITEAR ESTE ARCHIVO AL REPOSITORIO. LAS API KEYS EN GENERAL NO DEBEN COMMITEARSE. DE HACERLO DEBEN ELIMINARLAS Y CREAR NUEVAS__
    _

### Azure

- Crear una cuenta en Azure.
- Desde SSH Keys, generar un par de claves (key/secret). Dejar la clave privada en el directorio raíz del TP (o referenciarla con un link simbólico). Llamarla `key.pem`.
- Instalar [`Azure CLI`](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- Ejecutar `az login` e iniciar sesión en Azure. Pegar la __subscription ID__ (que se muestra luego del login exitoso) en una variable llamada __azure_sid__ en `terraform.tfvars`, debe quedar de esta manera:

```properties
azure_sid = "<Subscription ID de Azure>"
```

### Datadog

- Crear una cuenta con el [pack estudiantil de GitHub](https://education.github.com/pack) en [Datadog](https://www.datadoghq.com/)
- Ir a `<Usuario> -> Organization Settings -> API Keys` y obtener la API Key.
  - En `terraform.tfvars`, asignar el valor de la API key a una variable llamda __datadog_key__, debe quedar de esta manera:

```properties
datadog_key = "<API key de Datadog>"
```

- Verificar el host en la URL del navegador:
  - Si es __app.datadoghq.com__, saltear este paso.
  - Si en vez de "app" aparece otro nombre (por ejemplo, __us5.datadoghq.com__) ver las secciones de "Configuración adicional" más abajo.

### Terraform

- Instalar Terraform utilizando el package manager de la distribución de Linux que se utilice (recomendado), o descargándolo desde [aquí](https://www.terraform.io/downloads).

- Revisar el archivo `variables.tf` y actualizar los valores default de las variables que corresponda. Para "location", recomendamos utilizar "eastus2" o "westus2". Este archivo sí será commiteado, así que solo poner aquí valores default que puedan exponerse (para los demás, deben estar las variables definidas aquí pero los valores deben estar en `terraform.tfvars`, que nunca hay que commitearlo).
- Ejecutar `terraform init`. Esto inicializa la configuración que requiere terraform, e instala los providers necesarios.

### Ansible

- Instalar Ansible, ver [aquí](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) información para el SO que se tenga.
- Agregar el rol de Datadog para Ansible ejecutando: `ansible-galaxy install datadog.datadog`

#### Configuración adicional

Si en la verificación de Datadog encuentran que el host comienza con un string distinto a "app", deben editar el archivo `ansible/vmss_setup.yml` y colocar el hostname en la variable __datadog_site__.

## Correr los servidores

> __IMPORTANTE:__ En el script se utiliza el binario de `terraform`, asumiendo que se encuentra agregado a la variable `$PATH` (si lo instalan con un package manager, ya estará en el path).
>

Existe el script `start.sh` en la raíz del proyecto para crear la infraestructura y correr los servidores correspondientes.

```bash
# Seteo los permisos apropiados para que la key sea válida
chmod 400 key.pem
# Guardo la clave pública que obtuve de Azure
echo <PUBLIC_KEY> > pubkey

# Script que inicia sesión en Azure, crea la infraestructura, la inicializa y provisiona la app
./start.sh
```

Terraform crea un archivo local llamado `terraform.tfstate` que tiene el resultado de la aplicación del plan. Usa ese archivo luego para detectar diferencias y definir un nuevo plan si hay modificaciones a la infraestructura. Ese archivo **no debe perderse**, pero como [puede contener información sensible en texto plano](https://www.terraform.io/docs/state/sensitive-data.html) no es recomendable commitearlo sin tomar algunas precauciones. Además, si se destruye y regenera la infraestructura, cambiará mucho, con lo que es muy propenso a conflictos en git.

La recomendación, por lo tanto, es que cada cual tenga su propia cuenta de Azure y de Datadog, y mantenga su propio `terraform.tfstate` en su computadora sin necesidad de compartirlo. [Acá](https://www.terraform.io/docs/state/remote.html) tienen más información e instrucciones sobre qué hacer si quieren operar todos los integrantes del grupo sobre una misma cuenta de Azure y compartir su tfstate.

### Verificación

Una vez levantados los servidores, se puede verificar su correcto funcionamiento utilizando la URL que se encuentra dentro del archivo `lb_dns` de la carpeta `node` y enviando un request:

```sh
curl `cat node/lb_dns`
```

Lo cual chequeará que la app Node funciona.

### Respuestas

La aplicación Node deberá responder lo mismo que respondía en el TP 1, pero deberá encapsular lo que recibe de la API remota de manera tal que el JSON devuelto tenga esta estructura:

```JSON
{
    "id": "<GUID generado por el servicio que corre en el container>",
    "<nombre de la respuesta>": <cuerpo de la respuesta, ya sea texto u objeto>
}
```

El servicio que entrega GUIDs escuchará en la URI que se configura automáticamente en `node/config.js`. Responderá con un GUID en texto plano a cada request que reciba en `/`.

### Cambio de cantidad de instancias en el VMSS de la aplicación Node

Si se cambia la cantidad de instancias en el VMSS, una vez aplicados los cambios en la infraestructura, pueden ejecutar:

```sh
ansible/setup.sh
ansible/deploy.sh
```

Estos scripts actualizan el inventario con las direcciones IP de los nodos del VMSS y luego instalan la aplicación Node en cada uno. Puede ejecutarse todas las veces que sea necesario (si hay nodos que ya tienen las herramientas necesarias, para éstos la ejecución será más rápida).

Si sólo se modificó la app Node y se la quiere actualizar (sin haber cambiado la cantidad de instancias), pueden ejecutar el script de deploy únicamente:

```sh
ansible/deploy.sh
```

### Administración de la aplicación Node

El proyecto usa [pm2](https://pm2.keymetrics.io/) para daemonizar y administrar la aplicación Node. Pueden ver [aquí](https://pm2.keymetrics.io/docs/usage/quick-start/) documentación para acceder a los logs, detener y arrancar la aplicación, etc.

Si necesitan ingresar a alguna instancia de VMSS para ver logs o administrarla en general, deben ejecutar el siguiente comando desde la raíz del repositorio (reemplazando en el lugar apropiado por la IP interna de la instancia):

```sh
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand="ssh -o StrictHostKeyChecking=no -W %h:%p -q azureuser@$(cat ansible/jumpbox_dns) -i ./key.pem" -i ./key.pem azureuser@<IP privada del host>
```

Esto usa al Jumpbox de proxy SSH para evitar exponer con una IP pública a los nodos del VMSS. Utilizamos el mismo par de claves para el Jumpbox y los nodos por simplicidad. Normalmente se usan pares distintos.

### Envío de métricas a Datadog

El agente de Datadog se instala en cada instancia de Node automáticamente, cuando ejecutan el script `ansible/setup.sh` (el script `start.sh` lo invoca cuando crean la infraestructura).

Para enviar sus propias métricas, vean cómo hacerlo [aquí](https://docs.datadoghq.com/integrations/node/). Es muy sencillo porque el agente de Datadog abre el puerto de statsd en localhost y se encarga de enviar las métricas custom que recibe.

Para enviar métricas desde Artillery, vean la configuración [aquí](https://artillery.io/docs/guides/plugins/plugin-publish-metrics.html). Revisen el archivo `perf/run.sh` para colocar la API key en la variable `DATADOG_API_KEY`.

#### Configuración adicional

Si en la verificación de Datadog encuentran que el host comienza con un string distinto a "app", deben editar el archivo YAML de Artillery y colocar el hostname en la variable __apiHost__.

## Destruir la infraestructura

Cuando hayan terminado con el TP, pueden destruir la infraestructura con `terraform destroy`. Al par de claves que crearon a través de la UI de Azure deben eliminarlo desde la UI.

## Cheatsheet de Terraform

```sh
# Ver lista de comandos
terraform help

# Ver ayuda de un comando específico, como por ejemplo qué parámetros/opciones acepta
terraform <COMMAND> --help

# Ver la versión de terraform instalada
terraform version

# Inicializar terraform en el directorio. Esto instala los providers e inicializa archivos de terraform
terraform init

# Ver el plan de ejecución pero sin realizar ninguna acción sobre la infraestructura (no lo aplica)
terraform plan

# Aplicar los cambios de infraestructura. Requiere aprobación manual, a menos que se especifique la opción `-auto-approve`
terraform apply

# Destruir toda la infraestructura. Requiere aprobación manual, a menos que se especifique la opción `-force`
terraform destroy

# Verifica que la sintaxis y la semántica de los archivos sea válida
terraform validate

# Lista los providers instalados.
terraform providers
```
