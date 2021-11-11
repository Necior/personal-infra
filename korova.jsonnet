local private = import 'private.libsonnet';

{
  local app = self,
  local replicas = 1,

  deployment: {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: 'korova-deployment',
    },
    spec: {
      strategy: {
        type: 'Recreate',
      },
      selector: {
        matchLabels: {
          app: 'korova',
        },
      },
      replicas: replicas,
      template: {
        metadata: {
          labels: {
            app: 'korova',
          },
        },
        spec: {
          containers: [
            {
              name: 'korova',
              image: 'necior/korova:0.1.0',
              imagePullPolicy: 'Always',
              envFrom: [{ secretRef: { name: app.secret.metadata.name } }],
              resources: {
                requests: {
                  cpu: '0.001',
                  memory: '5Mi',
                },
                limits: {
                  cpu: '0.250',
                  memory: '10Mi',
                },
              },
            },
          ],

          tolerations: [
            {
              key: 'necior/arch',
              value: 'aarch64',
              effect: 'NoSchedule',
            },
          ],
        },
      },
    },
  },

  secret: {
    apiVersion: 'v1',
    kind: 'Secret',
    metadata: {
      name: 'korova-secrets',
    },
    data: {
      KOROVA_TOKEN: private.korova_token,
      KOROVA_OWM_APIKEY: private.korova_owm_apikey,
    },
  },
}