package hex.compiler.core;

#if macro
import hex.collection.Locator;
import hex.compiler.factory.DomainListenerFactory;
import hex.compiletime.basic.CompileTimeCoreFactory;
import hex.compiletime.basic.vo.FactoryVOTypeDef;
import hex.core.ContextTypeList;
import hex.core.IApplicationContext;
import hex.core.ICoreFactory;
import hex.core.SymbolTable;
import hex.vo.ConstructorVO;

/**
 * ...
 * @author Francis Bourre
 */
class StaticCompileTimeContextFactory 
	extends CompileTimeContextFactory
{
	static var _coreFactories 				: Map<String, ICoreFactory> = new Map();
	
	override public function init( applicationContext : IApplicationContext ) : Void
	{
		if ( !this._isInitialized )
		{
			this._isInitialized = true;
			
			this._applicationContext 				= applicationContext;
			this._coreFactory 						= cast ( applicationContext.getCoreFactory(), CompileTimeCoreFactory );
			
			if ( !StaticCompileTimeContextFactory._coreFactories.exists( applicationContext.getName() ) )
			{
				StaticCompileTimeContextFactory._coreFactories.set( this._applicationContext.getName(), cast ( applicationContext.getCoreFactory(), CompileTimeCoreFactory ) );
			}
			
			this._coreFactory = StaticCompileTimeContextFactory._coreFactories.get( this._applicationContext.getName() );
		
		//
			this._factoryMap 						= new Map();
			this._symbolTable 						= new SymbolTable();
			this._constructorVOLocator 				= new Locator();
			this._propertyVOLocator 				= new Locator();
			this._methodCallVOLocator 				= new Locator();
			this._typeLocator 						= new Locator();
			this._domainListenerVOLocator 			= new Locator();
			this._stateTransitionVOLocator 			= new Locator();
			this._moduleLocator 					= new Locator();
			this._mappedTypes 						= [];
			this._injectedInto 						= [];
			
			DomainListenerFactory.domainLocator = new Map();
			
			this._factoryMap.set( ContextTypeList.ARRAY, 			hex.compiletime.factory.ArrayFactory.build );
			this._factoryMap.set( ContextTypeList.BOOLEAN, 			hex.compiletime.factory.BoolFactory.build );
			this._factoryMap.set( ContextTypeList.INT, 				hex.compiletime.factory.IntFactory.build );
			this._factoryMap.set( ContextTypeList.NULL, 			hex.compiletime.factory.NullFactory.build );
			this._factoryMap.set( ContextTypeList.FLOAT, 			hex.compiletime.factory.FloatFactory.build );
			this._factoryMap.set( ContextTypeList.OBJECT, 			hex.compiletime.factory.DynamicObjectFactory.build );
			this._factoryMap.set( ContextTypeList.STRING, 			hex.compiletime.factory.StringFactory.build );
			this._factoryMap.set( ContextTypeList.UINT, 			hex.compiletime.factory.UIntFactory.build );
			this._factoryMap.set( ContextTypeList.DEFAULT, 			hex.compiletime.factory.StringFactory.build );
			this._factoryMap.set( ContextTypeList.HASHMAP, 			hex.compiletime.factory.HashMapFactory.build );
			this._factoryMap.set( ContextTypeList.CLASS, 			hex.compiletime.factory.ClassFactory.build );
			this._factoryMap.set( ContextTypeList.XML, 				hex.compiletime.factory.XmlFactory.build );
			this._factoryMap.set( ContextTypeList.FUNCTION, 		hex.compiletime.factory.FunctionFactory.build );
			this._factoryMap.set( ContextTypeList.STATIC_VARIABLE, 	hex.compiletime.factory.StaticVariableFactory.build );
			this._factoryMap.set( ContextTypeList.MAPPING_CONFIG, 	hex.compiletime.factory.MappingConfigurationFactory.build );
			
			this._coreFactory.addListener( this );
		}
	}

	override public function buildVO( constructorVO : ConstructorVO, ?id : String ) : Dynamic
	{
		constructorVO.shouldAssign 	= id != null;
		
		var type = constructorVO.className;
		var buildMethod : FactoryVOTypeDef->Dynamic = null;
		
		if ( this._factoryMap.exists( type ) )
		{
			buildMethod = this._factoryMap.get( type );
		}
		else if( constructorVO.ref != null )
		{
			buildMethod = hex.compiletime.factory.ReferenceFactory.build;
		}
		else
		{
			buildMethod = hex.compiler.factory.ClassInstanceFactory.build;
		}
		
		var result = buildMethod( this._getFactoryVO( constructorVO ) );

		if ( id != null )
		{
			this._tryToRegisterModule( constructorVO );
			this._parseInjectInto( constructorVO );
			this._parseMapTypes( constructorVO );
			
			var finalResult = result;
			finalResult = this._parseAnnotation( constructorVO, finalResult );
			finalResult = this._parseCommandTrigger( constructorVO, finalResult );
			
			hex.compiletime.util.ContextBuilder.getInstance( this ).addField( id, constructorVO.type );
			this._expressions.push( macro @:mergeBlock { $finalResult;  coreFactory.register( $v { id }, $i { id } ); this.$id = $i { id }; } );
			this._coreFactory.register( id, result );
		}

		return result;
	}
}
#end