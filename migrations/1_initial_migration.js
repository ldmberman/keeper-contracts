/* global artifacts */
const Migrations = artifacts.require('./Migrations.sol')

const initialMigration = (deployer) => {
    deployer.deploy(Migrations)
}

module.exports = initialMigration
