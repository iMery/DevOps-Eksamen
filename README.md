# PGR301 - Eksamen 2024
DevOps eksamen 2024 - kandidatnr 28

## OPPGAVE 1
A. 
**HTTP Endepunkt for Lambdafunksjonen:** 
```https://y2efwman4h.execute-api.eu-west-1.amazonaws.com/Prod/generate```

**For å teste APIet met POSTMAN:**
1. Gå til postman
2. Velg POST-metode og lim in URLen
3. I headers må det legges til: 
4. Legg til Body: `Content-Type: application/json`
```
{
  "prompt": "me on top of a pyramid"
}

```
5. Send og sjekk responsen. Et bilde skal være generert og lastet opp til `pgr301-couch-explorers` i folder `28/`

B.
**Lenke til kjørt Github actions workflow:** [Lenke til workflow](https://github.com/iMery/pgr301-eksamen/actions/runs/12017066121)


## OPPGAVE 2
**For å kjøre Terraform:**
1. `cd infra`
2. `terraform init`
3. `terraform plan -out=tfplan`
4. `terraform apply tfplan`
5. Når `terraform apply` kjøres kan SQS URLen som blir gitt ut brukes til å sende meldinger som genererer bilder og lagrer dem i S3-bucketen `pgr301-couch-explorers` i folder `images/`.

- **Deploy Terraform to main:** [Lenke til workflow](https://github.com/iMery/pgr301-eksamen/actions/runs/11983546334) - `terraform apply` kjøres.
- **Deploy Terraform to other branches:** [Lenke til workflow](https://github.com/iMery/pgr301-eksamen/actions/runs/11983812264) - `terraform plan` kjøres.
- **SQS URL:** `https://sqs.eu-west-1.amazonaws.com/244530008913/maqueue01`
  
## OPPGAVE 3
Jeg valgte "latest" som tag fordi det sikrer at brukerne alltid får den nyeste versjonen uten å måtte spesifisere en versjon. Dette gjør integrasjonen enkel og sørger for at oppdateringer kan publiseres raskt under aktiv utvikling, noe som passer for applikasjoner som behandler SQS-forespørsler og genererer bilder i en S3-bucket.

**For å kjøre container-image:**
1. Docker må være installert. 
2. AWS-nøkler kreves:`AWS_ACCESS_KEY_ID`&`AWS_SECRET_ACCESS_KEY`
3. Kopier og kjør kommandoen: 
```
docker run -e AWS_ACCESS_KEY_ID=AKIAXXXX \
           -e AWS_SECRET_ACCESS_KEY=XXXXXX \
           -e SQS_QUEUE_URL=https://sqs.eu-west-1.amazonaws.com/244530008913/maqueue01 \
           maka082/java-sqs-client "melding"
```

**Container image + SQS URL:**
- **Container image:** `maka082/java-sqs-client`
- **SQS URL:** `https://sqs.eu-west-1.amazonaws.com/244530008913/maqueue01`


## OPPGAVE 4
I denne oppgaven har jeg utvidet Terraform-koden ved å gjøre endringer i **variables.tf**, **main.tf** og **outputs.tf** for å sette opp CloudWatch-alarmen. Denne alarmen overvåker SQS metrikken **ApproximateAgeOfOldestMessage** og triggers når den eldeste meldingen i køren er mer enn 2 minutter gammel. Når alarmen utløses blir det varslet til en e-postadresse som er angitt i koden. Ved å bruke CloudWatch-alarm kan forsinkelser oppdages og håndteres raskt.

**Lenke til CloudWatch alarmen:** [CloudWatch-alarmen](https://eu-west-1.console.aws.amazon.com/cloudwatch/home?region=eu-west-1#alarmsV2:alarm/Oldest_message_Alarm_maka082?~(search~'maka))



## OPPGAVE 5


