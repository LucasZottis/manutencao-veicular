# Controle Veícular

Controle veícular é um aplicativo para Android para controle de serviços e abastecimentos realizados em seu veículo.

## Detalhes

O aplicativo oferece uma forma de controle de serviços e abastecimento de seu veículo, acompanhamento de serviços realizados e serviços que serão realizados, assim visualizando quanto que foi gasto e previsão de gastos futuros. Acompanhamento de abastecimento do veículo, controlando o consumo e valor por abastecimento.

## Funcionlidades

- Listagem e cadastro de veículo
- Dashboard para exibição de indicadores
- Histórico de abastecimentos e acompanhamento do consumo de combustível de seu veículo.
- Histórico de serviços realizados e acompanhamento para os futuros serviços.

## Telas

### Garagem

A tela "Garagem" é listado todos os veículos cadastrados. Uma lista de veículos aparece logo que entra na tela, exibindo informações de veículo como apelido, placa e quilometragem atual do veículo.
Para cadastrar um novo veículo é solicitado:

- Apelido para o veículo
- Odômetro atual
- Capacidade do tanque (opcional)
- Placa (opcional)
- Tipo de comustível aceito (opcional)

O tipo de combustível aceito é opcional, mas é recomendado informar para no momento do cadastro de abastecimento o aplicativo avise quando o tipo de combustível informado está divergente.

### Histórico Serviços

Lista de serviços realizados é acessado ao clicar em um veículo na garagem. 

- Total gasto no veículo com serviços.
- Filtrar por tela ano, mês e dia.

Para cadastrar um novo serviço é solicitado:

- O veículo vinculado ao serviço, caso tenha apenas um veículo na garagem será selecionado automaticamente.
- Data e hora (hora é opcional).
- Odômetro no momento do serviço.
- Valor do serviço.
- Descrição do serviço (opcional).
- Estabelecimento (opcional).
- Observação (opcional).
- Quilometragem até o próximo serviço (opcional, a quilometragem até o próximo serviço é para serviços recorrentes como troca de óleo, pneu e revisões.)

### Histórico de abastecimento

A lista de abastecimentos do seu veículo pode ser acesso clicando em seu veículo na garagem. Cada item da lista irá mostrar a data, o valor, quilometragem no momento do abastecimento e quantidade de litros total.

- Total gasto com combustível.
- Último abastecimento realizado.
- Consumo médio do veículo ao longo do tempo.
- Consumo médio desde o último abastecimento.

Para cadastrar um novo abastecimento será solicitado:

- O veículo vinculado ao serviço, caso tenha apenas um veículo na garagem será selecionado automaticamente.
- Data e hora (hora é opcional).
- Valor total pago
- Total de litros
- Valor por litro (opcional)
- Tipo de combustível (opcional)

*Caso o veículo aceite apenas um tipo de combustível, será selecionado automaticamente*

### *Ao cadastrar um serviço ou abastecimento é mostrado a opção de atualizar o odômetro atual do veículo com o odômetro no momento do cadastro. O odômetro do veículo não será atualizado caso o odômetro no momento do cadastro esteja abaixo.*
