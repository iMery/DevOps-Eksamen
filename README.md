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
2. AWS-nøkler kreves: `AWS_ACCESS_KEY_ID`&`AWS_SECRET_ACCESS_KEY`
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
I denne oppgaven har jeg utvidet Terraform-koden ved å gjøre endringer i **variables.tf**, **main.tf** og **outputs.tf** for å sette opp CloudWatch-alarmen. Denne alarmen overvåker SQS metrikken **ApproximateAgeOfOldestMessage** og triggers når den eldeste meldingen i køren er mer enn 2 minutter gammel. Når alarmen utløses blir det varslet til en e-postadresse som er angitt i koden. Ved å bruke CloudWatch-alarm kan forsinkelser oppdages og håndteres raskt. Jeg fikk ikke til å legge et bilde av alarmen så jeg legger ved en link av den.

**Lenke til CloudWatch alarmen:** [CloudWatch-alarmen](https://eu-west-1.console.aws.amazon.com/cloudwatch/home?region=eu-west-1#alarmsV2:alarm/Oldest_message_Alarm_maka082?~(search~'maka))


## OPPGAVE 5
**Serverless-arkitektur** er en måte å bygge og kjøre applikasjoner og tjenester på uten å måte administrere infrastrukturen selv. Applikasjonen vil fortsatt kjøre på servere, men all serveradministrasjon er gjort av f.eks AWS. Dette gjør at utviklere kan fokusere på koden og funksjonaliteten i applikasjonene, mens infrastrukturen tas hånd om i bakgrunnen. 

**Mikrotjenestearkitektur** er en måte å bygge store applikasjoner ved å dele dem opp i små tjenester. Hver mikrotjeneste har en spesifikk oppgave og disse tjenestene jobber sammen for å få applikasjonen til å fungere.

### 1. Automatisering og kontinuerlig levering (CI/CD)
---

**Serverless-arkitektur**

**Styrker:**

-	Kompleksiteten i CI/CD-piplines er redusert fordi infrastrukturen blir tatt hånd om i bakgrunnen av leverandøren (f.eks AWS).
-	Funksjoner kan oppdateres enkeltvis, slik at små endringer kan rulles ut raskt.
-	Sammenlignet med mikrotjenester kreves det mindre konfigurasjon og vedlikeholdet av miljøer.

**Svakheter:**

-	Avhengighet mellom funksjoner kan være vanskelig å teste før de distribueres. 
-	Mange små funksjoner kan gjøre utrullingsprosessene mer fragmenterte, og det kan kreve mer arbeid for å holde dem konsistente.

**Mikrotjenestearkitektur**

**Styrker:**

-	Uavhengige tjeneste gir mulighet for raskere oppdateringer og feilsøking.
-	Verktøy som Docker kan brukes for å sikre at miljøet er likt i utvikling, testing og produksjon. 
-	Som oftest er det tidlig skille mellom komponenter, noe som gjør CI/CD-pipelines mer oversiktlige.

**Svakheter:**

-	CI/CD piplines kan være mer komplekse siden hver tjeneste må bygges, testes og distribueres for seg selv. 
-	Flere tjenester kan føre til mer administrasjon og behov for robust overvåking. 

**Oppsummering:**

Serverless-arkitektur gir raskere utvikling og utrulling, men kan bli fragmentert på grunn av mange små funksjoner. Mikrotjenester gir mer strukturert og kontrollert CI/CD-prosess, men krever mer administrasjon. 


### 2. Observability (overvåkning)
---

**Serverless-arkitektur**

**Styrker:**

-	AWS CloudWatch overvåkingsverktøy gir innsikt i ytelse og hendelser på funksjonsnivå.
-	Hver funksjon har tidlige grenser, noe som kan gjøre det enklere å isolere feil. 

**Svakheter:**

-	Logging kan bli kostbart og krevende å administrere når mange små funksjoner genererer individuelle logger. 
-	Overvåkning kan bli fragmentert på grunn av antallet funskjoner.
-	Feilsøking på tvers av funksjoner kan være komplekst, særlig når meldingskøer som SQS er involvert.

**Mikrotjenestearkitektur**

**Styrker:**

-	Konsistent logging og sporing er enklere når tjenestene kjøres i containere.
-	Mulighet for tilpasset overvåking og rapportering, slik at hver tjeneste kan overvåkes etter sine spesifikke behov. 

**Svakheter:**
-	Kostnadene for overvåking og logging kan bli betydelige når antallet tjenester øker. 
-	Krever etablering av egen overvåkningsstruktur, som gjør at både kompleksiteten og ressursbruken øker. 
-	Det krever mye til og arbeid å sette opp overvåkning av distribuerte tjenester, og det gjør det utfordrende for temaet. 

**Oppsummering:**

Serverless-arkitektur gir enklere oppsett, men utfordrer helhetlig overvåkning. Mikrotjenester gir mer kontroll, men trenger mer innsats. 


### 3. Skalerbarhet og kostnadskontroll
---

**Serverless-arkitektur**

**Styrker:**

-	Skalerer automatisk etter behov, uten manuell innsats. 
-	Det blir kun betalt for tiden funksjonene er i bruk, noe som kan spare penger. 
-	Ressurser blir brukt kun når det er nødvendig, uten faste kostnader.

**Svakheter:**

-	Hvis funksjonene brukes ofte, kan kostnadene bli uforutsigbare.
-	Lite kontroll over ressursbruk og optimalisering.
-	«Cold-start» kan føre til forsinkelser når funksjonene aktiveres etter inaktivitet.

**Mikrotjenestearkitektur**

**Styrker:**

-	I mikrotjenestearkitektur kan hver tjeneste skaleres separat, noe som gir fleksibilitet. 
-	Ressursbruk kan optimaliseres manuelt, og kostnader er mer forutsigbare. 

**Svakheter:**

-	Krever mer tid og kunnskap for å håndtere infrastrukturen.
-	Konstant ressursbruk kan føre til høyere grunnkostnader.

**Oppsummering:**

Serverless-arkitektur skalerer automatisk, krever minimal administrasjon og er kostnadseffektiv, men har begrenset kontroll og uforutsigbare kostnader. Mikrotjenestearkitektur gir fleksibel skalering og bedre kontroll, men er dyrere og krever komplekse verktøy.


### 4. Eierskap og ansvar
---

**Serverless-arkitektur**

**Styrker:**

-	 Det er mindre ansvar for infrastruktur ettersom leverandører håndterer det. Det blir tatt hånd om oppdateringer og skalering og det frigjør tid for utviklere å fokusere på koden. 
-	Funksjoner som er automatiserte fir enklere administrasjon av ytelse og tilgjengelighet. 
-	Utviklere kan fokusere på optimalisering av applikasjonen mens leverandøren sikrer effektiv ressursbruk. 

**Svakheter:**

-	Avhengighet av leverandørens tjenester og pålitelighet påvirker applikasjonens ytelse og kostnader. 
-	Det er begrenset tilgang til infrastrukturdata og loggfiler, noe som gjør det vanskeligere å identifisere problemer. 
-	 Temaet har ikke mye mulighet til å justere infrastrukturen. Noe som påvirker ytelsen. 

**Mikrotjenestearkitektur**

**Styrker:**

-	Det kan bli brukt egne verktøy for loggføring, overvåking og feilretting. 
-	Mikrotjenester kan distribueres og vedlikeholdes uavhengig, noe som gir mulighet for optimalisering på tjenestenivå.
-	Full kontroll over infrastruktur og ytelse.

**Svakheter:**

-	Infrastrukturen må administreres av teamet. 
-	Krever høy kompetanse og kan vøre komplekst.
-	Teamet må sikre effektiv ressursbruk for å unngå høye kostnader. 

**Oppsummering:**

Serverless reduserer ansvar og kompleksitet, men gir mindre kontroll og avhengighet til leverandør. Mikrotjenester gir mer kontroll og fleksibilitet, men krever mer arbeid og økt ansvar.





