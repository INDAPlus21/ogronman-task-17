# ogronman-task-17

### Working-Allocators

##### Buffer allocator (`buffer.zig`)

##### Free-list (`freeList.zig`)

Run tests by:

```bash
zig build test
```

There will be one error since pool2Allocator does not work

### Work in progress

##### Pool-allocator (`pool2.zig`)

### Not Working

##### Pool-allocator (`pool.zig`)

##### buddy-allocator (`buddy.zig`)

##### stack-thing (`stack.zig`)


### Not implemented

##### some-allocator (`some.zig`)

#### The pool problem

Tänk dig att du vill spara en viss mängd vatten. Du vill kanske t.ex. spara 500 vatten. Det du gör då är att du skaffar 25 hinkar och fyller de hinkarna med 20 vatten, och sen dumpar du dem i poolen. Varje gång du ska ha en hink med vatten kan du då ta en hink, fylla den med vatten från poolen och sedan förflytta vattnet. I de flesta världar skulle det här vara rätt lätt, speciellt om man vet vad man gör... 

Men om jag har förstått zig rätt, så räcker det inte endast med att spara vattnet i poolen utan zig vill spara hinkarna också. Det här blir då ett problem, för det är då inte endast vattnet i hinkarna som tar upp plats i poolen utan hinkarna själva också. Så helt plötsligt har du inte bara 500 vatten, du har även 25 hinkar som ligger och flyter i poolen. Inte bra... Vad gör man? Svar: jag vet ej :/// 

Ska man


`1.` Göra en mycket större pool för att hålla koll på vattnet och hinkarna, men då blir det svårt att hålla koll på vad som är hink och vad som är vatten

`2.` Ska man bara ignorera hinkarna och låtsas att dem är vatten? Is-hinkar? Man tar upp dem ur vattnet och sen smälter de och blir vatten? Kanske fungerar, men en hink vatten tar upp mer plats än 20 vatten :/ Kan man spara en halv hink vatten?

`3.` Free-space

Och hur kommer man åt vattnet i hinkarna? :(
