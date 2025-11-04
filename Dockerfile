FROM quay.io/keycloak/keycloak:26.4.1

ENV KC_HEALTH_ENABLED=true \
    KC_METRICS_ENABLED=true

EXPOSE 8080

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start-dev", "--features=scripts", "--profile=preview"]
