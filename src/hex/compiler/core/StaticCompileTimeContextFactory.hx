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
	static var _coreFactories : Map<String, ICoreFactory> = new Map();
	
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
			this._factoryMap = hex.compiler.core.CompileTimeSettings.factoryMap;
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
	
			if ( constructorVO.abstractType != null )
			{
				hex.compiletime.util.ContextBuilder.getInstance( this ).addFieldWithClassName( id, constructorVO.abstractType, constructorVO.filePosition, (constructorVO.lazy?result:null) );
			}
			else if ( constructorVO.cType != null )
			{
				hex.compiletime.util.ContextBuilder.getInstance( this ).addField( id, constructorVO.cType, constructorVO.filePosition, (constructorVO.lazy?result:null) );
			}
			else
			{
				hex.compiletime.util.ContextBuilder.getInstance( this ).addFieldWithClassName( id, constructorVO.type, constructorVO.filePosition, (constructorVO.lazy?result:null) );
			}

			if ( !constructorVO.lazy )
			{
				this._expressions.push( macro @:mergeBlock { $finalResult;  coreFactory.register( $v { id }, $i { id } ); this.$id = $i { id }; } );
			}
			
			this._coreFactory.register( id, result );
		}

		return result;
	}
}
#end