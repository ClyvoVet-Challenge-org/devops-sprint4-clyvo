#
# VERIFIQUE SE ESTA COM A ASSINATURA CORRRETA
#
# az account show
# az account list -o table
# az account set --subscription "nome-da-assinatura-correta"


# Variáveis
RESOURCE_GROUP_NAME="rg-sprint4-clyvo-rm565698"
WEBAPP_NAME="sprint4-clyvo-rm565698"
APP_SERVICE_PLAN="sprint4-clyvo-rm565698"
LOCATION="canadacentral"
RUNTIME="JAVA:21-java21"
APP_INSIGHTS_NAME="ai-sprint4-clyvo-rm565698"
USERNAME="rm565698"
PASSWORD="200591"
URL="jdbc:oracle:thin:@//oracle.fiap.com.br:1521/ORCL"


# Registrar os Serviços utilizados
az provider register --namespace Microsoft.Web
az provider register --namespace Microsoft.Insights
az provider register --namespace Microsoft.OperationalInsights
az provider register --namespace Microsoft.ServiceLinker

# Registrar a extensão utilizada
az extension add --name application-insights

# Criação do Grupo de Recursos
az group create \
  --name $RESOURCE_GROUP_NAME \
  --location "$LOCATION"
  
# Criar Application Insights
az monitor app-insights component create \
  --app $APP_INSIGHTS_NAME \
  --location "$LOCATION" \
  --resource-group $RESOURCE_GROUP_NAME \
  --application-type web


# Criar o Plano de Serviço
az appservice plan create \
  --name $APP_SERVICE_PLAN \
  --resource-group $RESOURCE_GROUP_NAME \
  --location "$LOCATION" \
  --sku F1 \
  --is-linux


# Criar o Serviço de Aplicativo
az webapp create \
  --name $WEBAPP_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --plan $APP_SERVICE_PLAN \
  --runtime "$RUNTIME"

# Recuperar a String de Conexão do Application Insights (assim podemos nos conectar a esse App Insights)
CONNECTION_STRING=$(az monitor app-insights component show \
  --app $APP_INSIGHTS_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --query connectionString \
  --output tsv)

# Configurar as Variáveis de Ambiente necessárias do nosso App e do Application Insights
az webapp config appsettings set \
  --name "$WEBAPP_NAME" \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --settings \
    APPLICATIONINSIGHTS_CONNECTION_STRING="$CONNECTION_STRING" \
    ApplicationInsightsAgent_EXTENSION_VERSION="~3" \
    XDT_MicrosoftApplicationInsights_Mode="Recommended" \
    XDT_MicrosoftApplicationInsights_PreemptSdk="1" \
    SPRING_DATASOURCE_USERNAME="$USERNAME" \
    SPRING_DATASOURCE_PASSWORD="$PASSWORD" \
    SPRING_DATASOURCE_URL="$URL"

# Reiniciar o Web App
az webapp restart --name $WEBAPP_NAME --resource-group $RESOURCE_GROUP_NAME

# Criar a conexão do nosso Web App com o Application Insights
az monitor app-insights component connect-webapp \
    --app $APP_INSIGHTS_NAME \
    --web-app $WEBAPP_NAME \
    --resource-group $RESOURCE_GROUP_NAME






