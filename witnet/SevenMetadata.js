import * as Witnet from "witnet-requests"

const sevenData = new Witnet.Source("https://seven-data.by-syl.com/json/1.json")
    .parseJSONMap()
    .getArray("attributes")
    .filter(
        new Witnet.Script([Witnet.TYPES.MAP])
            .getString("trait_type")
            .match({
                "SE7EN Mood": true,
                "Signature pose": true,
            }, false)
    ).map(
        new Witnet.Script([Witnet.TYPES.MAP])
            .getString("value")
    )

const aggregator = Witnet.Aggregator.mode()

const tally = Witnet.Tally.mode()

const query = new Witnet.Query()
    .addSource(sevenData)
    .setAggregator(aggregator) // Set the aggregator function
    .setTally(tally) // Set the tally function

// Do not forget to export the query object
export { query as default }