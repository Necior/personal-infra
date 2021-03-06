local private = import 'private.libsonnet';
local links = ['<a href="https://' + e[0] + '">' + e[1] + '</a><br/>' for e in std.sort([
  [private.elm_playground_domain, 'Todo app'],
  [private.elm_pomodoro_domain, 'Pomodoro'],
  [private.mongo_express_domain, 'Mongo Express'],
  [private.httpmongo_domain, 'httpmongo'],
  [private.unstable_http_server_domain, 'unstable-http-server'],
  [private.homepage_domain, 'home'],
  [private.sssnek_domain, 'Sssnek'],
  [private.adminer_domain, 'Adminer'],
  [private.grafana_domain, 'Grafana'],
  [private.dokuwiki_domain, 'Wiki'],
], function(x) std.asciiLower(x[1]))];
local html = '<!doctype html><html lang="en"><title>meta</title><body>' + std.join(' ', links);

{
  local app = self,
  local replicas = 1,

  deployment: {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: 'meta-deployment',
    },
    spec: {
      selector: {
        matchLabels: {
          app: 'meta',
        },
      },
      replicas: replicas,
      template: {
        metadata: {
          labels: {
            app: 'meta',
          },
        },
        spec: {
          containers: [
            {
              name: 'meta',
              image: 'nginx:1.21.4',
              imagePullPolicy: 'IfNotPresent',
              command: ['/bin/sh', '-c', 'echo ' + std.base64(html) + ' | base64 -d > /usr/share/nginx/html/index.html && nginx -g daemon\\ off\\;'],
              resources: {
                requests: {
                  cpu: '0.001',
                  memory: '3Mi',
                },
                limits: {
                  cpu: '0.250',
                  memory: '10Mi',
                },
              },
              ports: [
                {
                  containerPort: 80,
                },
              ],
            },
          ],
          tolerations: [
            {
              key: 'necior/arch',
              value: 'aarch64',
              effect: 'NoSchedule',
            },
            {
              key: 'necior/arch',
              value: 'x86_64',
              effect: 'NoSchedule',
            },
          ],
        },
      },
    },
  },

  service: {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: 'meta-service',
    },
    spec: {
      selector: {
        app: 'meta',
      },
      ports: [
        {
          protocol: 'TCP',
          port: 80,
          targetPort: app.deployment.spec.template.spec.containers[0].ports[0].containerPort,
        },
      ],
    },
  },

  ingress: {
    apiVersion: 'networking.k8s.io/v1',
    kind: 'Ingress',
    metadata: {
      name: 'meta-ingress',
    },
    spec: {
      tls: [{ hosts: private.domains, secretName: 'domain-cert-tls' }],
      rules: [
        {
          host: private.meta_domain,
          http:
            {
              paths: [
                {
                  path: '/',
                  pathType: 'Prefix',
                  backend: {
                    service: {
                      name: app.service.metadata.name,
                      port: {
                        number: app.service.spec.ports[0].port,
                      },
                    },
                  },
                },
              ],
            },
        },
      ],
    },
  },
}
