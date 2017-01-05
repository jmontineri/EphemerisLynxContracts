var Web3 = require("web3");
var SolidityEvent = require("web3/lib/web3/event.js");

(function() {
  // Planned for future features, logging, etc.
  function Provider(provider) {
    this.provider = provider;
  }

  Provider.prototype.send = function() {
    this.provider.send.apply(this.provider, arguments);
  };

  Provider.prototype.sendAsync = function() {
    this.provider.sendAsync.apply(this.provider, arguments);
  };

  var BigNumber = (new Web3()).toBigNumber(0).constructor;

  var Utils = {
    is_object: function(val) {
      return typeof val == "object" && !Array.isArray(val);
    },
    is_big_number: function(val) {
      if (typeof val != "object") return false;

      // Instanceof won't work because we have multiple versions of Web3.
      try {
        new BigNumber(val);
        return true;
      } catch (e) {
        return false;
      }
    },
    merge: function() {
      var merged = {};
      var args = Array.prototype.slice.call(arguments);

      for (var i = 0; i < args.length; i++) {
        var object = args[i];
        var keys = Object.keys(object);
        for (var j = 0; j < keys.length; j++) {
          var key = keys[j];
          var value = object[key];
          merged[key] = value;
        }
      }

      return merged;
    },
    promisifyFunction: function(fn, C) {
      var self = this;
      return function() {
        var instance = this;

        var args = Array.prototype.slice.call(arguments);
        var tx_params = {};
        var last_arg = args[args.length - 1];

        // It's only tx_params if it's an object and not a BigNumber.
        if (Utils.is_object(last_arg) && !Utils.is_big_number(last_arg)) {
          tx_params = args.pop();
        }

        tx_params = Utils.merge(C.class_defaults, tx_params);

        return new Promise(function(accept, reject) {
          var callback = function(error, result) {
            if (error != null) {
              reject(error);
            } else {
              accept(result);
            }
          };
          args.push(tx_params, callback);
          fn.apply(instance.contract, args);
        });
      };
    },
    synchronizeFunction: function(fn, instance, C) {
      var self = this;
      return function() {
        var args = Array.prototype.slice.call(arguments);
        var tx_params = {};
        var last_arg = args[args.length - 1];

        // It's only tx_params if it's an object and not a BigNumber.
        if (Utils.is_object(last_arg) && !Utils.is_big_number(last_arg)) {
          tx_params = args.pop();
        }

        tx_params = Utils.merge(C.class_defaults, tx_params);

        return new Promise(function(accept, reject) {

          var decodeLogs = function(logs) {
            return logs.map(function(log) {
              var logABI = C.events[log.topics[0]];

              if (logABI == null) {
                return null;
              }

              var decoder = new SolidityEvent(null, logABI, instance.address);
              return decoder.decode(log);
            }).filter(function(log) {
              return log != null;
            });
          };

          var callback = function(error, tx) {
            if (error != null) {
              reject(error);
              return;
            }

            var timeout = C.synchronization_timeout || 240000;
            var start = new Date().getTime();

            var make_attempt = function() {
              C.web3.eth.getTransactionReceipt(tx, function(err, receipt) {
                if (err) return reject(err);

                if (receipt != null) {
                  // If they've opted into next gen, return more information.
                  if (C.next_gen == true) {
                    return accept({
                      tx: tx,
                      receipt: receipt,
                      logs: decodeLogs(receipt.logs)
                    });
                  } else {
                    return accept(tx);
                  }
                }

                if (timeout > 0 && new Date().getTime() - start > timeout) {
                  return reject(new Error("Transaction " + tx + " wasn't processed in " + (timeout / 1000) + " seconds!"));
                }

                setTimeout(make_attempt, 1000);
              });
            };

            make_attempt();
          };

          args.push(tx_params, callback);
          fn.apply(self, args);
        });
      };
    }
  };

  function instantiate(instance, contract) {
    instance.contract = contract;
    var constructor = instance.constructor;

    // Provision our functions.
    for (var i = 0; i < instance.abi.length; i++) {
      var item = instance.abi[i];
      if (item.type == "function") {
        if (item.constant == true) {
          instance[item.name] = Utils.promisifyFunction(contract[item.name], constructor);
        } else {
          instance[item.name] = Utils.synchronizeFunction(contract[item.name], instance, constructor);
        }

        instance[item.name].call = Utils.promisifyFunction(contract[item.name].call, constructor);
        instance[item.name].sendTransaction = Utils.promisifyFunction(contract[item.name].sendTransaction, constructor);
        instance[item.name].request = contract[item.name].request;
        instance[item.name].estimateGas = Utils.promisifyFunction(contract[item.name].estimateGas, constructor);
      }

      if (item.type == "event") {
        instance[item.name] = contract[item.name];
      }
    }

    instance.allEvents = contract.allEvents;
    instance.address = contract.address;
    instance.transactionHash = contract.transactionHash;
  };

  // Use inheritance to create a clone of this contract,
  // and copy over contract's static functions.
  function mutate(fn) {
    var temp = function Clone() { return fn.apply(this, arguments); };

    Object.keys(fn).forEach(function(key) {
      temp[key] = fn[key];
    });

    temp.prototype = Object.create(fn.prototype);
    bootstrap(temp);
    return temp;
  };

  function bootstrap(fn) {
    fn.web3 = new Web3();
    fn.class_defaults  = fn.prototype.defaults || {};

    // Set the network iniitally to make default data available and re-use code.
    // Then remove the saved network id so the network will be auto-detected on first use.
    fn.setNetwork("default");
    fn.network_id = null;
    return fn;
  };

  // Accepts a contract object created with web3.eth.contract.
  // Optionally, if called without `new`, accepts a network_id and will
  // create a new version of the contract abstraction with that network_id set.
  function Contract() {
    if (this instanceof Contract) {
      instantiate(this, arguments[0]);
    } else {
      var C = mutate(Contract);
      var network_id = arguments.length > 0 ? arguments[0] : "default";
      C.setNetwork(network_id);
      return C;
    }
  };

  Contract.currentProvider = null;

  Contract.setProvider = function(provider) {
    var wrapped = new Provider(provider);
    this.web3.setProvider(wrapped);
    this.currentProvider = provider;
  };

  Contract.new = function() {
    if (this.currentProvider == null) {
      throw new Error("Factory error: Please call setProvider() first before calling new().");
    }

    var args = Array.prototype.slice.call(arguments);

    if (!this.unlinked_binary) {
      throw new Error("Factory error: contract binary not set. Can't deploy new instance.");
    }

    var regex = /__[^_]+_+/g;
    var unlinked_libraries = this.binary.match(regex);

    if (unlinked_libraries != null) {
      unlinked_libraries = unlinked_libraries.map(function(name) {
        // Remove underscores
        return name.replace(/_/g, "");
      }).sort().filter(function(name, index, arr) {
        // Remove duplicates
        if (index + 1 >= arr.length) {
          return true;
        }

        return name != arr[index + 1];
      }).join(", ");

      throw new Error("Factory contains unresolved libraries. You must deploy and link the following libraries before you can deploy a new version of Factory: " + unlinked_libraries);
    }

    var self = this;

    return new Promise(function(accept, reject) {
      var contract_class = self.web3.eth.contract(self.abi);
      var tx_params = {};
      var last_arg = args[args.length - 1];

      // It's only tx_params if it's an object and not a BigNumber.
      if (Utils.is_object(last_arg) && !Utils.is_big_number(last_arg)) {
        tx_params = args.pop();
      }

      tx_params = Utils.merge(self.class_defaults, tx_params);

      if (tx_params.data == null) {
        tx_params.data = self.binary;
      }

      // web3 0.9.0 and above calls new twice this callback twice.
      // Why, I have no idea...
      var intermediary = function(err, web3_instance) {
        if (err != null) {
          reject(err);
          return;
        }

        if (err == null && web3_instance != null && web3_instance.address != null) {
          accept(new self(web3_instance));
        }
      };

      args.push(tx_params, intermediary);
      contract_class.new.apply(contract_class, args);
    });
  };

  Contract.at = function(address) {
    if (address == null || typeof address != "string" || address.length != 42) {
      throw new Error("Invalid address passed to Factory.at(): " + address);
    }

    var contract_class = this.web3.eth.contract(this.abi);
    var contract = contract_class.at(address);

    return new this(contract);
  };

  Contract.deployed = function() {
    if (!this.address) {
      throw new Error("Cannot find deployed address: Factory not deployed or address not set.");
    }

    return this.at(this.address);
  };

  Contract.defaults = function(class_defaults) {
    if (this.class_defaults == null) {
      this.class_defaults = {};
    }

    if (class_defaults == null) {
      class_defaults = {};
    }

    var self = this;
    Object.keys(class_defaults).forEach(function(key) {
      var value = class_defaults[key];
      self.class_defaults[key] = value;
    });

    return this.class_defaults;
  };

  Contract.extend = function() {
    var args = Array.prototype.slice.call(arguments);

    for (var i = 0; i < arguments.length; i++) {
      var object = arguments[i];
      var keys = Object.keys(object);
      for (var j = 0; j < keys.length; j++) {
        var key = keys[j];
        var value = object[key];
        this.prototype[key] = value;
      }
    }
  };

  Contract.all_networks = {
  "default": {
    "abi": [
      {
        "constant": false,
        "inputs": [],
        "name": "createID",
        "outputs": [
          {
            "name": "",
            "type": "address"
          }
        ],
        "payable": false,
        "type": "function"
      },
      {
        "constant": false,
        "inputs": [
          {
            "name": "newOwner",
            "type": "address"
          }
        ],
        "name": "changeOwner",
        "outputs": [],
        "payable": false,
        "type": "function"
      }
    ],
    "unlinked_binary": "0x60606040525b60008054600160a060020a03191633600160a060020a03161790555b5b61111a806100316000396000f300606060405263ffffffff60e060020a60003504166348573542811461002f578063a6f9dae114610058575b610000565b346100005761003c610073565b60408051600160a060020a039092168252519081900360200190f35b3461000057610071600160a060020a0360043516610109565b005b600060006040516109118061025383396040519101819003906000f0801561000057905080600160a060020a031663a6f9dae1336040518263ffffffff1660e060020a0281526004018082600160a060020a0316600160a060020a03168152602001915050600060405180830381600087803b156100005760325a03f11561000057505050610102813361014e565b91505b5090565b60005433600160a060020a0390811691161415610149576000805473ffffffffffffffffffffffffffffffffffffffff1916600160a060020a0383161790555b5b5b50565b600060008360405161058b80610b648339600160a060020a03909216910190815260405190819003602001906000f0801561000057905083600160a060020a031663a6f9dae1826040518263ffffffff1660e060020a0281526004018082600160a060020a0316600160a060020a03168152602001915050600060405180830381600087803b156100005760325a03f1156100005750505080600160a060020a031663a6f9dae1846040518263ffffffff1660e060020a0281526004018082600160a060020a0316600160a060020a03168152602001915050600060405180830381600087803b156100005760325a03f115610000575050508091505b5092915050560060606040525b60008054600160a060020a03191633600160a060020a03161790555b5b6108e0806100316000396000f300606060405236156100675763ffffffff60e060020a600035041663277c9467811461006c57806341c0e1b51461008e578063a0d3dd8d1461009d578063a6f9dae1146100ac578063e7996f07146100c7578063eb43e033146100f3578063fe9be4cc1461011f575b610000565b346100005761007c60043561018f565b60408051918252519081900360200190f35b346100005761009b6101b0565b005b346100005761009b6101f1565b005b346100005761009b600160a060020a03600435166102a9565b005b34610000576100d76004356102e1565b60408051600160a060020a039092168252519081900360200190f35b34610000576100d760043561031e565b60408051600160a060020a039092168252519081900360200190f35b346100005760408051602060046024803582810135601f81018590048502860185019096528585526100d7958335959394604494939290920191819084018382808284375094965061033c95505050505050565b60408051600160a060020a039092168252519081900360200190f35b600281815481101561000057906000526020600020900160005b5054905081565b60005433600160a060020a03908116911614156101ec5760005433600160a060020a03908116911614156101ec57600054600160a060020a0316ff5b5b5b5b565b600080548190819033600160a060020a03908116911614156102a257505060025460005b60025481101561025057600281815481101561000057906000526020600020900160005b50549250610246836102e1565b505b600101610215565b6002805460008083559190915261029f907f405787fa12a823e0f2b7631cc41b3ba8828b3321ca811111fa75cd3aa3bb5ace908101905b8082111561029b5760008155600101610287565b5090565b5b505b5b5b505050565b60005433600160a060020a03908116911614156102dc5760008054600160a060020a031916600160a060020a0383161790555b5b5b50565b6000805433600160a060020a0390811691161415610317575060008181526001602052604081208054600160a060020a03191690555b5b5b919050565b600081815260016020526040902054600160a060020a03165b919050565b6000805433600160a060020a039081169116141561048c578160405161042080610495833960209101818152825182820152825190918291604083019185019080838382156103a6575b8051825260208311156103a657601f199092019160209182019101610386565b505050905090810190601f1680156103d25780820380516001836020036101000a031916815260200191505b5092505050604051809103906000f080156100005760008481526001602081905260409091208054600160a060020a031916600160a060020a03939093169290921790915560028054918201808255909190828183801582901161045b5760008381526020902061045b9181019083015b8082111561029b5760008155600101610287565b5090565b5b505050916000526020600020900160005b508490555050600082815260016020526040902054600160a060020a03165b5b5b92915050560060606040523461000057604051610420380380610420833981016040528051015b5b60008054600160a060020a03191633600160a060020a03161790555b6100538164010000000061013761005a82021704565b5b50610113565b60005433600160a060020a039081169116141561010e578060019080519060200190828054600181600116156101000203166002900490600052602060002090601f016020900481019282601f106100bd57805160ff19168380011785556100ea565b828001600101855582156100ea579182015b828111156100ea5782518255916020019190600101906100cf565b5b5061010b9291505b8082111561010757600081556001016100f3565b5090565b50505b5b5b50565b6102fe806101226000396000f300606060405263ffffffff60e060020a600035041663827bfbdf811461003a578063a6f9dae11461008f578063ce2ce3fc146100aa575b610000565b346100005761008d600480803590602001908201803590602001908080601f0160208091040260200160405190810160405280939291908181526020018383808284375094965061013795505050505050565b005b346100005761008d600160a060020a03600435166101f0565b005b34610000576100b7610235565b6040805160208082528351818301528351919283929083019185019080838382156100fd575b8051825260208311156100fd57601f1990920191602091820191016100dd565b505050905090810190601f1680156101295780820380516001836020036101000a031916815260200191505b509250505060405180910390f35b60005433600160a060020a03908116911614156101eb578060019080519060200190828054600181600116156101000203166002900490600052602060002090601f016020900481019282601f1061019a57805160ff19168380011785556101c7565b828001600101855582156101c7579182015b828111156101c75782518255916020019190600101906101ac565b5b506101e89291505b808211156101e457600081556001016101d0565b5090565b50505b5b5b50565b60005433600160a060020a03908116911614156101eb576000805473ffffffffffffffffffffffffffffffffffffffff1916600160a060020a0383161790555b5b5b50565b604080516020808201835260008252600180548451600282841615610100026000190190921691909104601f8101849004840282018401909552848152929390918301828280156102c75780601f1061029c576101008083540402835291602001916102c7565b820191906000526020600020905b8154815290600101906020018083116102aa57829003601f168201915b505050505090505b905600a165627a7a72305820ab6699a9b6a4f8828d57681f598de6c48f7b9ebee0816fbe1af09b1c309855070029a165627a7a723058206d2476d6eef9d829ba8fac955d5e5f947a8920a21dfb89acffe316183b4dabd400296060604052346100005760405160208061058b83398101604052515b5b60008054600160a060020a03191633600160a060020a03161790555b60018054600160a060020a031916600160a060020a0383161790555b505b610526806100656000396000f3006060604052361561005c5763ffffffff60e060020a6000350416637ca307b48114610061578063a0d3dd8d14610070578063a6f9dae11461007f578063e7996f071461009a578063eb43e033146100c6578063fe9be4cc146100f2575b610000565b346100005761006e610162565b005b346100005761006e610209565b005b346100005761006e600160a060020a036004351661028a565b005b34610000576100aa6004356102cf565b60408051600160a060020a039092168252519081900360200190f35b34610000576100aa60043561036a565b60408051600160a060020a039092168252519081900360200190f35b346100005760408051602060046024803582810135601f81018590048502860185019096528585526100aa95833595939460449493929092019181908401838280828437509496506103ea95505050505050565b60408051600160a060020a039092168252519081900360200190f35b60005433600160a060020a039081169116141561020457600154604080517f41c0e1b50000000000000000000000000000000000000000000000000000000081529051600160a060020a03909216916341c0e1b59160048082019260009290919082900301818387803b156100005760325a03f11561000057505060005433600160a060020a0390811691161415905061020457600054600160a060020a0316ff5b5b5b5b565b60005433600160a060020a039081169116141561020457600154604080517fa0d3dd8d0000000000000000000000000000000000000000000000000000000081529051600160a060020a039092169163a0d3dd8d9160048082019260009290919082900301818387803b156100005760325a03f115610000575050505b5b5b565b60005433600160a060020a03908116911614156102ca576000805473ffffffffffffffffffffffffffffffffffffffff1916600160a060020a0383161790555b5b5b50565b6000805433600160a060020a039081169116141561036357600154604080516000602091820181905282517fe7996f07000000000000000000000000000000000000000000000000000000008152600481018790529251600160a060020a039094169363e7996f079360248082019493918390030190829087803b156100005760325a03f115610000575050604051519150505b5b5b919050565b600154604080516000602091820181905282517feb43e0330000000000000000000000000000000000000000000000000000000081526004810186905292519093600160a060020a03169263eb43e03392602480830193919282900301818787803b156100005760325a03f115610000575050604051519150505b919050565b6000805433600160a060020a03908116911614156104f25760015460408051600060209182015281517ffe9be4cc0000000000000000000000000000000000000000000000000000000081526004810187815260248201938452865160448301528651600160a060020a039095169463fe9be4cc94899489949192606490920191908501908083838215610499575b80518252602083111561049957601f199092019160209182019101610479565b505050905090810190601f1680156104c55780820380516001836020036101000a031916815260200191505b509350505050602060405180830381600087803b156100005760325a03f115610000575050604051519150505b5b5b929150505600a165627a7a7230582019ce25dcbc7cd033c8b5900afe418edcd2af7e031f7d05cf685ed3abc40e99ad0029a165627a7a723058209274327e5fa0cd0cfa8cd34c5606120260a0cfc1300b02c8503425f9d9b038590029",
    "events": {},
    "updated_at": 1483635086838
  }
};

  Contract.checkNetwork = function(callback) {
    var self = this;

    if (this.network_id != null) {
      return callback();
    }

    this.web3.version.network(function(err, result) {
      if (err) return callback(err);

      var network_id = result.toString();

      // If we have the main network,
      if (network_id == "1") {
        var possible_ids = ["1", "live", "default"];

        for (var i = 0; i < possible_ids.length; i++) {
          var id = possible_ids[i];
          if (Contract.all_networks[id] != null) {
            network_id = id;
            break;
          }
        }
      }

      if (self.all_networks[network_id] == null) {
        return callback(new Error(self.name + " error: Can't find artifacts for network id '" + network_id + "'"));
      }

      self.setNetwork(network_id);
      callback();
    })
  };

  Contract.setNetwork = function(network_id) {
    var network = this.all_networks[network_id] || {};

    this.abi             = this.prototype.abi             = network.abi;
    this.unlinked_binary = this.prototype.unlinked_binary = network.unlinked_binary;
    this.address         = this.prototype.address         = network.address;
    this.updated_at      = this.prototype.updated_at      = network.updated_at;
    this.links           = this.prototype.links           = network.links || {};
    this.events          = this.prototype.events          = network.events || {};

    this.network_id = network_id;
  };

  Contract.networks = function() {
    return Object.keys(this.all_networks);
  };

  Contract.link = function(name, address) {
    if (typeof name == "function") {
      var contract = name;

      if (contract.address == null) {
        throw new Error("Cannot link contract without an address.");
      }

      Contract.link(contract.contract_name, contract.address);

      // Merge events so this contract knows about library's events
      Object.keys(contract.events).forEach(function(topic) {
        Contract.events[topic] = contract.events[topic];
      });

      return;
    }

    if (typeof name == "object") {
      var obj = name;
      Object.keys(obj).forEach(function(name) {
        var a = obj[name];
        Contract.link(name, a);
      });
      return;
    }

    Contract.links[name] = address;
  };

  Contract.contract_name   = Contract.prototype.contract_name   = "Factory";
  Contract.generated_with  = Contract.prototype.generated_with  = "3.2.0";

  // Allow people to opt-in to breaking changes now.
  Contract.next_gen = false;

  var properties = {
    binary: function() {
      var binary = Contract.unlinked_binary;

      Object.keys(Contract.links).forEach(function(library_name) {
        var library_address = Contract.links[library_name];
        var regex = new RegExp("__" + library_name + "_*", "g");

        binary = binary.replace(regex, library_address.replace("0x", ""));
      });

      return binary;
    }
  };

  Object.keys(properties).forEach(function(key) {
    var getter = properties[key];

    var definition = {};
    definition.enumerable = true;
    definition.configurable = false;
    definition.get = getter;

    Object.defineProperty(Contract, key, definition);
    Object.defineProperty(Contract.prototype, key, definition);
  });

  bootstrap(Contract);

  if (typeof module != "undefined" && typeof module.exports != "undefined") {
    module.exports = Contract;
  } else {
    // There will only be one version of this contract in the browser,
    // and we can use that.
    window.Factory = Contract;
  }
})();
