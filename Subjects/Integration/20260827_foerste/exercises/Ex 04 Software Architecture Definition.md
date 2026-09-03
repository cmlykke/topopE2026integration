### Software Architecture Definition
Work in groups of 5.

You need to define the architecture for **GameHub**, which sells downloadable video games.

The system consists of six components:

- A. **User Management**. Standard CRUD for users, addresses and preferences. UI → business logic → persistence.
---------------- layerd (korrekt)
- B. **Payment Gateway**. GameHub must support MobilePay, PayPal and credit cards. Providers should be replaceable without modifying the business logic.
---------------- hexagonal  (korrekt)
- C. **Game Catalogue**. Thousands of catalogue reads for every update. The model used to search/display games differs substantially from the model used by publishers to maintain them.
---------------- CQRS   (korrekt)
- D. **Purchase History**. Every purchase, refund and correction must be retained. The current state must be reconstructable from everything that has happened.
---------------- event sourcing  (korrekt)
- E. **Discount Engine**. Different discount mechanisms can be installed: seasonal sale, student discount, publisher campaign, loyalty discount, etc. New mechanisms should be addable without changing the core application.
---------------- microkernel  (korrekt)
- F. **Store Backend**. Users, catalogue administration, shopping cart and orders share a single deployment and database, but the code should have strong boundaries between these functional areas.
---------------- modular monolith   (korrekt)

#### Part One
Match each component with its corresponding application pattern (layered, hexagonal, CQRS, event sourcing, microkernel, modular monolith).

#### Part Two
GameHub has:
- One development team
- 6 developers
- 20,000 customers
- Moderate traffic
- Limited infrastructure budget
- No requirement for independent deployment of different business areas

Which is the most appropriate software architecture (monolith, N-tier, enterprise SOA, microservices)?

-------------------------------- monolith or N-tier
================================  (kan vaere begge)

#### Part Three
GameHub consists of:
- Web Store
- Mobile App
- Order Service
- Payment Service
- Notification Service

When a customer buys a game, the following happens:
1. The Web Store or Mobile App sends the purchase to the Order Service
2. The Order Service asks the Payment Service to process the payment
3. After successful payment, the Order Service asks the Notification Service to send a receipt

Questions:
1. Which component acts as both a service provider and a service requester?
---------------------------------- Payment Service er baade requester og provider for order service. 
2. Which service is reused by more than one requester?
--------------------------------- Order Service bruges af baade Web Store og Mobile App
   ================================ forkert. det er orderservice. (fordi payment ikke instruere orderservice - kun konfirmation)



#### Part Four
Three years pass and GameHub has:
- 8 million users
- 10 development teams
- Very high catalogue traffic
- Global releases generating enormous traffic peaks
- Different parts of the system requiring independent deployment

Questions:
1. Which overall architecture becomes more attractive now?
----------------------  microservicecs eller serverless (er SOA brugbar her?)
´++++++++++++++++++++++++  Microservice er korrekt (serverless ikke naevnt)
2. Which three components would you adapt to the new architecture first?
---------------------   ??? maaske:
---------------------  **Game Catalogue**   CQRS
---------------------   **Discount Engine**  microkernel
---------------------   **Store Backend**    modular monolith

----------------------  eventuelt User Management (layerd) istedet for Game Catalogue

=========================== Game catalogue has a lot of traffic, den bruger CQRS og den er derfor mere konplex.
                            og hvis den bare er lidt langsom, saa kan den faa brugerne til at forlade platformen.
                             
                           purchase history has a lot of data, == den er kritisk. den skal vaere auditable.
                           derfor er den en prioritet.
                 
                            payment gateway --- igen fordi dens data er meget vigtig.

                            de 3 er vigtigst. for de oevrige kan man diskutere det. 
                           


